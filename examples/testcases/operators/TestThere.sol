pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { DataTypes as types } from "ovm-contracts/DataTypes.sol";
import "ovm-contracts/UniversalAdjudicationContract.sol";
import "ovm-contracts/Utils.sol";
import "ovm-contracts/Predicate/AtomicPredicate.sol";
import "ovm-contracts/Predicate/CompiledPredicate.sol";


/**
 * ThereTest()
 */
contract ThereTest {
    bytes public ThereTestT = bytes("ThereTestT");

    UniversalAdjudicationContract adjudicationContract;
    Utils utils;
    address IsLessThan = address(0x0000000000000000000000000000000000000000);
    address Equal = address(0x0000000000000000000000000000000000000000);
    address IsValidSignature = address(0x0000000000000000000000000000000000000000);
    address IsContained = address(0x0000000000000000000000000000000000000000);
    address VerifyInclusion = address(0x0000000000000000000000000000000000000000);
    address IsSameAmount = address(0x0000000000000000000000000000000000000000);
    address IsConcatenatedWith = address(0x0000000000000000000000000000000000000000);
    address IsValidHash = address(0x0000000000000000000000000000000000000000);
    address IsStored = address(0x0000000000000000000000000000000000000000);
    address notAddress = address(0x0000000000000000000000000000000000000000);
    address andAddress = address(0x0000000000000000000000000000000000000000);
    address forAllSuchThatAddress = address(0x0000000000000000000000000000000000000000);
    address public payoutContractAddress;
    bool isInitialized = false;

    constructor(
        address _adjudicationContractAddress,
        address _utilsAddress,
        address _notAddress,
        address _andAddress,
        address _forAllSuchThatAddress
    ) public {
        adjudicationContract = UniversalAdjudicationContract(_adjudicationContractAddress);
        utils = Utils(_utilsAddress);
        notAddress = _notAddress;
        andAddress = _andAddress;
        forAllSuchThatAddress = _forAllSuchThatAddress;
    }

    function setPredicateAddresses(
        address _isLessThan,
        address _equal,
        address _isValidSignature,
        address _isContained,
        address _verifyInclusion,
        address _isSameAmount,
        address _isConcatenatedWith,
        address _isValidHash,
        address _isStored,
        address _payoutContractAddress
    ) public {
        require(!isInitialized, "isInitialized must be false");
        IsLessThan = _isLessThan;
        Equal = _equal;
        IsValidSignature = _isValidSignature;
        IsContained = _isContained;
        VerifyInclusion = _verifyInclusion;
        IsSameAmount = _isSameAmount;
        IsConcatenatedWith = _isConcatenatedWith;
        IsValidHash = _isValidHash;
        IsStored = _isStored;
        payoutContractAddress = _payoutContractAddress;
        isInitialized = true;
    }
    
    /**
     * @dev Validates a child node of the property in game tree.
     */
    function isValidChallenge(
        bytes[] memory _inputs,
        bytes[] memory _challengeInput,
        types.Property memory _challenge
    ) public view returns (bool) {
        require(
            keccak256(abi.encode(getChild(_inputs, _challengeInput))) == keccak256(abi.encode(_challenge)),
            "_challenge must be valud child of game tree"
        );
        return true;
    }
    
    function getChild(
        bytes[] memory inputs,
        bytes[] memory challengeInput
    ) private view returns (types.Property memory) {
        if(!utils.isLabel(inputs[0])) {
            return getChildThereTestT(inputs, challengeInput);
        }
        bytes32 input0 = keccak256(utils.getInputValue(inputs[0]));
        bytes[] memory subInputs = utils.subArray(inputs, 1, inputs.length);
        if(input0 == keccak256(ThereTestT)) {
            return getChildThereTestT(subInputs, challengeInput);
        }
    }

    /**
     * @dev check the property is true
     */
    function decide(bytes[] memory _inputs, bytes[] memory _witness) public view returns(bool) {
        if(!utils.isLabel(_inputs[0])) {
            return decideThereTestT(_inputs, _witness);
        }
        bytes32 input0 = keccak256(utils.getInputValue(_inputs[0]));
        bytes[] memory subInputs = utils.subArray(_inputs, 1, _inputs.length);
        if(input0 == keccak256(ThereTestT)) {
            return decideThereTestT(subInputs, _witness);
        }
    }

    function decideTrue(bytes[] memory _inputs, bytes[] memory _witness) public {
        require(decide(_inputs, _witness), "must be true");
        types.Property memory property = types.Property({
            predicateAddress: address(this),
            inputs: _inputs
        });
        adjudicationContract.setPredicateDecision(utils.getPropertyId(property), true);
    }

    /**
     * Gets child of ThereTestT(ThereTestT).
     */
    function getChildThereTestT(bytes[] memory _inputs, bytes[] memory challengeInputs) private view returns (types.Property memory) {
        bytes[] memory forAllSuchThatInputs = new bytes[](3);
        bytes[] memory notInputs = new bytes[](1);
        bytes[] memory childInputsOf = new bytes[](1);
        childInputsOf[0] = bytes("Va");

        notInputs[0] = abi.encode(types.Property({
            predicateAddress: Foo,
            inputs: childInputsOf
        }));

        forAllSuchThatInputs[0] = bytes("");
        forAllSuchThatInputs[1] = bytes("a");
        forAllSuchThatInputs[2] = abi.encode(types.Property({
            predicateAddress: notAddress,
            inputs: notInputs
        }));
        return types.Property({
            predicateAddress: forAllSuchThatAddress,
            inputs: forAllSuchThatInputs
        });
    }
    /**
     * Decides ThereTestT(ThereTestT).
     */
    function decideThereTestT(bytes[] memory _inputs, bytes[] memory _witness) public view returns (bool) {
        // check ThereExistsSuchThat

        bytes[] memory childInputs = new bytes[](1);
        childInputs[0] = _witness[0];
        require(
            AtomicPredicate(Foo).decide(childInputs),
            "Foo must be true"
        );

        return true;
    }

}

