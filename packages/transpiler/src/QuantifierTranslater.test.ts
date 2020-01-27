import { applyLibraries } from './QuantifierTranslater'
import { PropertyDef, Parser } from '@cryptoeconomicslab/ovm-parser'
import Coder from '@cryptoeconomicslab/coder'
import { setupContext } from '@cryptoeconomicslab/context'
setupContext({ coder: Coder })

describe('QuantifierTranslater', () => {
  beforeEach(async () => {})
  describe('applyLibraries', () => {
    test('SignedBy', () => {
      const input: PropertyDef[] = [
        {
          annotations: [],
          name: 'SignedByTest',
          inputDefs: ['a', 'b'],
          body: {
            type: 'PropertyNode',
            predicate: 'ThereExistsSuchThat',
            inputs: [
              {
                type: 'PropertyNode',
                predicate: 'SignedBy',
                inputs: ['a', 'b']
              }
            ]
          }
        }
      ]
      const library: PropertyDef[] = [
        {
          annotations: [
            {
              type: 'Annotation',
              body: {
                name: 'quantifier',
                args: ['signatures,KEY,${message}']
              }
            }
          ],
          name: 'SignedBy',
          inputDefs: ['sig', 'message', 'public_key'],
          body: {
            type: 'PropertyNode',
            predicate: 'IsValidSignature',
            inputs: ['message', 'sig', 'public_key', '$secp256k1']
          }
        }
      ]
      const output = applyLibraries(input, library)
      expect(output).toStrictEqual([
        {
          annotations: [],
          name: 'SignedByTest',
          inputDefs: ['a', 'b'],
          body: {
            type: 'PropertyNode',
            predicate: 'ThereExistsSuchThat',
            inputs: [
              'signatures,KEY,${a}',
              'v0',
              {
                type: 'PropertyNode',
                predicate: 'IsValidSignature',
                inputs: ['a', 'v0', 'b', '$secp256k1']
              }
            ]
          }
        }
      ])
    })

    test('IsLessThan', () => {
      const input: PropertyDef[] = [
        {
          annotations: [],
          name: 'LessThanTest',
          inputDefs: ['b'],
          body: {
            type: 'PropertyNode',
            predicate: 'ForAllSuchThat',
            inputs: [
              {
                type: 'PropertyNode',
                predicate: 'IsLessThan',
                inputs: ['b']
              },
              'bb',
              {
                type: 'PropertyNode',
                predicate: 'Foo',
                inputs: ['bb']
              }
            ]
          }
        }
      ]
      const library: PropertyDef[] = [
        {
          annotations: [
            {
              type: 'Annotation',
              body: {
                name: 'quantifier',
                args: ['range,NUMBER,${zero}-${upper_bound}']
              }
            }
          ],
          name: 'IsLessThan',
          inputDefs: ['n', 'upper_bound'],
          body: {
            type: 'PropertyNode',
            predicate: 'IsLessThan',
            inputs: ['n', 'upper_bound']
          }
        }
      ]

      const output = applyLibraries(input, library)
      expect(output).toStrictEqual([
        {
          annotations: [],
          name: 'LessThanTest',
          inputDefs: ['b'],
          body: {
            type: 'PropertyNode',
            predicate: 'ForAllSuchThat',
            inputs: [
              'range,NUMBER,0x223022-${b}',
              'bb',
              {
                type: 'PropertyNode',
                predicate: 'Or',
                inputs: [
                  {
                    type: 'PropertyNode',
                    predicate: 'Not',
                    inputs: [
                      {
                        type: 'PropertyNode',
                        predicate: 'IsLessThan',
                        inputs: ['bb', 'b']
                      }
                    ]
                  },
                  { type: 'PropertyNode', predicate: 'Foo', inputs: ['bb'] }
                ]
              }
            ]
          }
        }
      ])
    })

    test('SU', () => {
      const input: PropertyDef[] = [
        {
          annotations: [],
          name: 'SUTest',
          inputDefs: ['token', 'range', 'block'],
          body: {
            type: 'PropertyNode',
            predicate: 'ForAllSuchThat',
            inputs: [
              {
                type: 'PropertyNode',
                predicate: 'SU',
                inputs: ['token', 'range', 'block']
              },
              'su',
              {
                type: 'PropertyNode',
                predicate: 'Foo',
                inputs: ['su']
              }
            ]
          }
        }
      ]
      const parser = new Parser()
      const library: PropertyDef[] = parser.parse(`
@quantifier("proof.block\${t}.range\${r},RANGE,\${b}")
def IncludedAt(p, l, t, r, b) := 
  VerifyInclusion(l, t, r, b, p)

def IncludedWithin(su, b, t, r) := 
  IncludedAt(su, su.0, su.1, b).any()
  and Equal(su.0, t)
  and IsContained(su.1, range)
        
@quantifier("su.block\${token}.range\${range},RANGE,\${block}")
def SU(su, token, range, block) := IncludedWithin(su, block, token, range)
      `).declarations
      const output = applyLibraries(input, library)
      console.log(JSON.stringify(output))
      expect(output).toStrictEqual([
        {
          annotations: [],
          name: 'SUTest',
          inputDefs: ['token', 'range', 'block'],
          body: {
            type: 'PropertyNode',
            predicate: 'ForAllSuchThat',
            inputs: [
              'su.block${token}.range${range},RANGE,${block}',
              'su',
              {
                type: 'PropertyNode',
                predicate: 'Or',
                inputs: [
                  {
                    type: 'PropertyNode',
                    predicate: 'Not',
                    inputs: [
                      {
                        type: 'PropertyNode',
                        predicate: 'And',
                        inputs: [
                          {
                            type: 'PropertyNode',
                            predicate: 'ThereExistsSuchThat',
                            inputs: [
                              'su.block${token}.range${range},RANGE,${block}',
                              'proof0',
                              {
                                type: 'PropertyNode',
                                predicate: 'VerifyInclusion',
                                inputs: [
                                  'su',
                                  'su.0',
                                  'su.1',
                                  'proof0',
                                  'token'
                                ]
                              }
                            ]
                          },
                          {
                            type: 'PropertyNode',
                            predicate: 'Equal',
                            inputs: ['su.0', 'range']
                          },
                          {
                            type: 'PropertyNode',
                            predicate: 'IsContained',
                            inputs: ['su.1', 'block']
                          }
                        ]
                      }
                    ]
                  },
                  { type: 'PropertyNode', predicate: 'Foo', inputs: ['su'] }
                ]
              }
            ]
          }
        }
      ])
    })

    test('Tx', () => {
      const input: PropertyDef[] = [
        {
          annotations: [],
          name: 'TxTest',
          inputDefs: ['token', 'range', 'block'],
          body: {
            type: 'PropertyNode',
            predicate: 'ThereExistsSuchThat',
            inputs: [
              {
                type: 'PropertyNode',
                predicate: 'Tx',
                inputs: ['token', 'range', 'block']
              },
              'tx',
              {
                type: 'PropertyNode',
                predicate: 'Foo',
                inputs: ['tx']
              }
            ]
          }
        }
      ]
      const parser = new Parser()
      const library: PropertyDef[] = parser.parse(`
def IsTx(tx, t, r, b) := 
  Equal(tx.address, $TransactionAddress)
  and Equal(tx.0, t)
  and IsContained(tx.1, range)
  and IsLessThan(tx.2, b)
        
@quantifier("tx.block\${block}.range\${token},RANGE,\${range}")
def Tx(tx, token, range, block) := IsTx(tx, token, range, block)
      `).declarations
      const output = applyLibraries(input, library)
      expect(output).toStrictEqual([
        {
          annotations: [],
          name: 'TxTest',
          inputDefs: ['token', 'range', 'block'],
          body: {
            type: 'PropertyNode',
            predicate: 'ThereExistsSuchThat',
            inputs: [
              'tx.block${block}.range${token},RANGE,${range}',
              'tx',
              {
                type: 'PropertyNode',
                predicate: 'And',
                inputs: [
                  {
                    type: 'PropertyNode',
                    predicate: 'And',
                    inputs: [
                      {
                        type: 'PropertyNode',
                        predicate: 'Equal',
                        inputs: ['tx.address', '$TransactionAddress']
                      },
                      {
                        type: 'PropertyNode',
                        predicate: 'Equal',
                        inputs: ['tx.0', 'token']
                      },
                      {
                        type: 'PropertyNode',
                        predicate: 'IsContained',
                        inputs: ['tx.1', 'range']
                      },
                      {
                        type: 'PropertyNode',
                        predicate: 'IsLessThan',
                        inputs: ['tx.2', 'block']
                      }
                    ]
                  },
                  { type: 'PropertyNode', predicate: 'Foo', inputs: ['tx'] }
                ]
              }
            ]
          }
        }
      ])
    })
  })
})
