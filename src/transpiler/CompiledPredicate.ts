/**
 * Compiled Property definition
 */
export interface CompiledPredicate {
  type: 'CompiledPredicate'
  name: string
  inputDefs: string[]
  contracts: IntermediateCompiledPredicate[]
  constants?: ConstantVariable[]
  entryPoint: string
}

export interface ConstantVariable {
  varType: 'address' | 'bytes'
  name: string
}

export interface IntermediateCompiledPredicate {
  type: 'IntermediateCompiledPredicate'
  isCompiled: boolean
  originalPredicateName: string
  definition: IntermediateCompiledPredicateDef
}

export interface IntermediateCompiledPredicateDef {
  type: 'IntermediateCompiledPredicateDef'
  name: string
  // logical connective
  connective: LogicalConnective
  inputDefs: string[]
  inputs: (AtomicProposition | Placeholder)[]
  propertyInputs: NormalInput[]
}

export interface AtomicProposition {
  type: 'AtomicProposition'
  predicate: Predicate
  inputs: CompiledInput[]
  isCompiled?: boolean
}

export type Placeholder = string

export type Predicate = AtomicPredicate | InputPredicate | VariablePredicate

export interface AtomicPredicate {
  type: 'AtomicPredicate'
  source: string
}

export interface InputPredicate {
  type: 'InputPredicate'
  source: NormalInput
}

export interface VariablePredicate {
  type: 'VariablePredicate'
}

/**
 * challengeInput -1
 * inputs[0] is 0
 * inputs[0].inputs[0] is [0, 0]
 */
export type CompiledInput =
  | ConstantInput
  | LabelInput
  | NormalInput
  | VariableInput
  | SelfInput

export interface ConstantInput {
  type: 'ConstantInput'
  name: string
}

export interface LabelInput {
  type: 'LabelInput'
  label: string
}

export interface NormalInput {
  type: 'NormalInput'
  inputIndex: number
  children: number[]
}

export interface VariableInput {
  type: 'VariableInput'
  placeholder: string
  children: number[]
}

export interface SelfInput {
  type: 'SelfInput'
  children: number[]
}

// LogicalConnective
export enum LogicalConnective {
  And = 'And',
  ForAllSuchThat = 'ForAllSuchThat',
  Not = 'Not',
  Or = 'Or',
  ThereExistsSuchThat = 'ThereExistsSuchThat'
}

export type LogicalConnectiveStrings = keyof typeof LogicalConnective

export function convertStringToLogicalConnective(
  name: LogicalConnectiveStrings
): LogicalConnective {
  return LogicalConnective[name]
}
