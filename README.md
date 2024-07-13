
### Compilation
- Compiling...
- Compiling 1 file with Solc 0.8.20
- Solc 0.8.20 finished in 1.62s
- Compiler run successful!

### Test Suites

#### Suite: `test/nft_market_invariants_test.sol:NftMarketHandler`
- **[PASS]** `testBuyItem(address)` (runs: 260, μ: 173214, ~: 173214)
- **[PASS]** `testListItem()` (gas: 71692)
- **Result**: 2 passed; 0 failed; 0 skipped; finished in 27.68ms (22.17ms CPU time)

#### Suite: `test/nft_market_test.sol:NftMarketTest`
- **[PASS]** `testBoughtEvent()` (gas: 177714)
- **[PASS]** `testBoughtItem()` (gas: 176803)
- **[PASS]** `testBuyNftwithLessThanSalePrice()` (gas: 135849)
- **[PASS]** `testBuyNftwithMoreThanSalePrice()` (gas: 196847)
- **[PASS]** `testFuzzBoughtItem(address)` (runs: 259, μ: 177329, ~: 177329)
- **[PASS]** `testFuzzListItem(uint256)` (runs: 261, μ: 69226, ~: 69836)
- **[PASS]** `testFuzzlistandBuy(address,uint256)` (runs: 257, μ: 175321, ~: 175321)
- **[PASS]** `testListItem()` (gas: 71953)
- **[PASS]** `testListItemEvent()` (gas: 77128)
- **[PASS]** `testListItemNotApproval()` (gas: 22660)
- **[PASS]** `testRepeatBoughtSameItem()` (gas: 235954)
- **[PASS]** `testSelfBoughtItem()` (gas: 131276)
- **Result**: 12 passed; 0 failed; 0 skipped; finished in 84.56ms (117.56ms CPU time)

#### Suite: `test/nft_market_invariants_test.sol:NftMarketInvariants`
- **[PASS]** `invariant_ntfmarket_nft_balance_equal_0()` (runs: 256, calls: 128000, reverts: 42448)
- **Result**: 1 passed; 0 failed; 0 skipped; finished in 11.02s (11.01s CPU time)

### Summary
- Ran 3 test suites in 11.03s (11.13s CPU time): 
  - 15 tests passed, 0 failed, 0 skipped (15 total tests)
