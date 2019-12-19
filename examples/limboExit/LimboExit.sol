pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { DataTypes as types } from "ovm-contracts/DataTypes.sol";
import "ovm-contracts/UniversalAdjudicationContract.sol";
import "ovm-contracts/Utils.sol";
import "ovm-contracts/Predicate/AtomicPredicate.sol";
import "ovm-contracts/Predicate/CompiledPredicate.sol";


/**
 * LimboExit(prev_su,tx,su)
 */
contract LimboExit {
    bytes public LimboExitO2A = bytes("LimboExitO2A");
    bytes public LimboExitO = bytes("LimboExitO");

    UniversalAdjudicationContract adjudicationContract;
    Utils utils;
    address IsLessThan = address(0x0000000000000000000000000000000000000000);
    address Equal = address(0x0000000000000000000000000000000000000000);
    address IsValidSignature = address(0x0000000000000000000000000000000000000000);
    address IsContained = address(0x0000000000000000000000000000000000000000);
    address VerifyInclusion = address(0x0000000000000000000000000000000000000000);
    address IsSameAmount = address(0x0000000000000000000000000000000000000000);
    address notAddress = address(0x0000000000000000000000000000000000000000);
    address andAddress = address(0x0000000000000000000000000000000000000000);
    address forAllSuchThatAddress = address(0x0000000000000000000000000000000000000000);
    address IsValidStateTransition;
    address Exit;

    constructor(
        address _adjudicationContractAddress,
        address _utilsAddress,
        address _isLessThan,
        address _equal,
        address _isValidSignature,
        address _isContained,
        address _verifyInclusion,
        address _isSameAmount,
        address _notAddress,
        address _andAddress,
        address _forAllSuchThatAddress,
        address  _IsValidStateTransition,
        address  _Exit
    ) public {
        adjudicationContract = UniversalAdjudicationContract(_adjudicationContractAddress);
        utils = Utils(_utilsAddress);
        IsLessThan = _isLessThan;
        Equal = _equal;
        IsValidSignature = _isValidSignature;
        IsContained = _isContained;
        VerifyInclusion = _verifyInclusion;
        IsSameAmount = _isSameAmount;
        notAddress = _notAddress;
        forAllSuchThatAddress = _forAllSuchThatAddress;
        IsValidStateTransition = _IsValidStateTransition;
        Exit = _Exit;
    }

    /**
     * @dev Validates a child node of the property in game tree.
     */
    function isValidChallenge(
        bytes[] memory _inputs,
        bytes[] memory _challengeInput,
        types.Property memory _challenge
    ) public returns (bool) {
        require(
            keccak256(abi.encode(getChild(_inputs, _challengeInput))) == keccak256(abi.encode(_challenge)),
            "_challenge must be valud child of game tree"
        );
        return true;
    }

    function getChild(
        bytes[] memory inputs,
        bytes[] memory challengeInput
    ) private returns (types.Property memory) {
        bytes32 input0 = keccak256(inputs[0]);
        if(input0 == keccak256(LimboExitO2A)) {
            return getChildLimboExitO2A(inputs, challengeInput);
        }
        if(input0 == keccak256(LimboExitO)) {
            return getChildLimboExitO(inputs, challengeInput);
        }
    }

    /**
     * @dev check the property is true
     */
    function decide(bytes[] memory _inputs, bytes[] memory _witness) public view returns(bool) {
        bytes32 input0 = keccak256(_inputs[0]);
        if(input0 == keccak256(LimboExitO2A)) {
            decideLimboExitO2A(_inputs, _witness);
        }
        if(input0 == keccak256(LimboExitO)) {
            decideLimboExitO(_inputs, _witness);
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
     * Gets child of LimboExitO2A(LimboExitO2A,prev_su,tx,su).
     */
    function getChildLimboExitO2A(bytes[] memory _inputs, bytes[] memory challengeInputs) private returns (types.Property memory) {
        uint256 challengeInput = abi.decode(challengeInputs[0], (uint256));
        bytes[] memory notInputs = new bytes[](1);
        if(challengeInput == 0) {
            notInputs[0] = _inputs[1];
        }
        if(challengeInput == 1) {
            bytes[] memory childInputsOf1 = new bytes[](3);
            childInputsOf1[0] = _inputs[1];
            childInputsOf1[1] = _inputs[2];
            childInputsOf1[2] = _inputs[3];

            notInputs[0] = abi.encode(types.Property({
                predicateAddress: IsValidStateTransition,
                inputs: childInputsOf1
            }));

        }
        if(challengeInput == 2) {
            bytes[] memory childInputsOf2 = new bytes[](1);
            childInputsOf2[0] = _inputs[3];

            notInputs[0] = abi.encode(types.Property({
                predicateAddress: Exit,
                inputs: childInputsOf2
            }));

        }
        return types.Property({
            predicateAddress: notAddress,
            inputs: notInputs
        });
    }
    /**
     * Gets child of LimboExitO(LimboExitO,prev_su,tx,su).
     */
    function getChildLimboExitO(bytes[] memory _inputs, bytes[] memory challengeInputs) private returns (types.Property memory) {

        bytes[] memory andInputs = new bytes[](2);
        bytes[] memory notInputs0 = new bytes[](1);
        bytes[] memory childInputsOf0 = new bytes[](1);
        childInputsOf0[0] = _inputs[1];

        notInputs0[0] = abi.encode(types.Property({
            predicateAddress: Exit,
            inputs: childInputsOf0
        }));

        andInputs[0] = abi.encode(types.Property({
            predicateAddress: notAddress,
            inputs: notInputs0
        }));
        bytes[] memory notInputs1 = new bytes[](1);
        bytes[] memory childInputsOf1 = new bytes[](4);
        childInputsOf1[0] = LimboExitO2A;
        childInputsOf1[1] = _inputs[1];
        childInputsOf1[2] = _inputs[2];
        childInputsOf1[3] = _inputs[3];

        notInputs1[0] = abi.encode(types.Property({
            predicateAddress: address(this),
            inputs: childInputsOf1
        }));

        andInputs[1] = abi.encode(types.Property({
            predicateAddress: notAddress,
            inputs: notInputs1
        }));
        return types.Property({
            predicateAddress: andAddress,
            inputs: andInputs
        });
    }
    /**
     * Decides LimboExitO2A(LimboExitO2A,prev_su,tx,su).
     */
    function decideLimboExitO2A(bytes[] memory _inputs, bytes[] memory _witness) public view returns (bool) {
        // And logical connective

        require(adjudicationContract.isDecidedById(keccak256(_inputs[1])));


        bytes[] memory childInputs1 = new bytes[](3);
        childInputs1[0] = _inputs[1];
        childInputs1[1] = _inputs[2];
        childInputs1[2] = _inputs[3];
        require(AtomicPredicate(IsValidStateTransition).decide(childInputs1));


        bytes[] memory childInputs2 = new bytes[](1);
        childInputs2[0] = _inputs[3];
        require(AtomicPredicate(Exit).decide(childInputs2));

        return true;
    }
    /**
     * Decides LimboExitO(LimboExitO,prev_su,tx,su).
     */
    function decideLimboExitO(bytes[] memory _inputs, bytes[] memory _witness) public view returns (bool) {
        // check Or
        uint256 orIndex = abi.decode(_witness[0], (uint256));
        if(orIndex == 0) {
            bytes[] memory childInputs0 = new bytes[](1);
            childInputs0[0] = _inputs[1];

            bytes[] memory childInputs0 = new bytes[](1);
            childInputs0[0] = _inputs[1];
            require(AtomicPredicate(Exit).decide(childInputs0));

        }
        if(orIndex == 1) {
            bytes[] memory childInputs1 = new bytes[](4);
            childInputs1[0] = LimboExitO2A;
            childInputs1[1] = _inputs[1];
            childInputs1[2] = _inputs[2];
            childInputs1[3] = _inputs[3];
            require(decideLimboExitO2A(childInputs1,  utils.subArray(_witness, 1, _witness.length)));

        }
        return true;
    }

}

