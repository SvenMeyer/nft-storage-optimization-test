import { expect } from "chai";
import { ethers } from "hardhat";

import { StoragePatterns } from "../../typechain-types/StoragePatterns";

// Helper function to add some delay to ensure storage operations complete
function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

describe("NFT Properties Storage Test", function () {
  let nftPropertiesTest: StoragePatterns;

  beforeEach(async function () {
    // Deploy a fresh contract for each test
    const StoragePatternsFactory = await ethers.getContractFactory("StoragePatterns");
    nftPropertiesTest = (await StoragePatternsFactory.deploy()) as StoragePatterns;
  });

  it("should compare gas costs for different NFT property storage patterns", async function () {
    // Use the same test values for all approaches
    const testValues = Array.from({ length: 16 }, (_, i) => i + 1); // 1 to 16
    
    // Measure gas for minting with individual properties
    const tx1 = await nftPropertiesTest.mintWithIndividualProperties(testValues);
    const receipt1 = await tx1.wait();
    if (!receipt1) throw new Error("Transaction failed");
    const individualGas = receipt1.gasUsed;
    const tokenId1 = await nftPropertiesTest.totalMinted() - BigInt(1);
    
    // Measure gas for minting with array properties
    const tx2 = await nftPropertiesTest.mintWithArrayProperties(testValues);
    const receipt2 = await tx2.wait();
    if (!receipt2) throw new Error("Transaction failed");
    const arrayGas = receipt2.gasUsed;
    const tokenId2 = await nftPropertiesTest.totalMinted() - BigInt(1);
    
    // Measure gas for minting with packed bytes32 properties
    const tx3 = await nftPropertiesTest.mintWithPackedProperties(testValues);
    const receipt3 = await tx3.wait();
    if (!receipt3) throw new Error("Transaction failed");
    const bytes32Gas = receipt3.gasUsed;
    const tokenId3 = await nftPropertiesTest.totalMinted() - BigInt(1);
    
    // Measure gas for minting with struct properties
    const tx4 = await nftPropertiesTest.mintWithStructProperties(testValues);
    const receipt4 = await tx4.wait();
    if (!receipt4) throw new Error("Transaction failed");
    const structGas = receipt4.gasUsed;
    const tokenId4 = await nftPropertiesTest.totalMinted() - BigInt(1);
    
    // Measure gas for minting with struct containing array properties
    const tx5 = await nftPropertiesTest.mintWithStructArrayProperties(testValues);
    const receipt5 = await tx5.wait();
    if (!receipt5) throw new Error("Transaction failed");
    const structArrayGas = receipt5.gasUsed;
    const tokenId5 = await nftPropertiesTest.totalMinted() - BigInt(1);
    
    // Measure gas for minting with a packed struct containing uint32 + uint16[14] array
    const tx6 = await nftPropertiesTest.mintWithPackedArrayStruct(testValues);
    const receipt6 = await tx6.wait();
    if (!receipt6) throw new Error("Transaction failed");
    const packedArrayStructGas = receipt6.gasUsed;
    const tokenId6 = await nftPropertiesTest.totalMinted() - BigInt(1);
    
    // Ensure all storage operations have completed
    await delay(100);
    
    // Verify that all approaches stored the values correctly by checking sums
    const individualSum = await nftPropertiesTest.getIndividualPropertiesSum(tokenId1);
    const arraySum = await nftPropertiesTest.getArrayPropertiesSum(tokenId2);
    const bytes32Sum = await nftPropertiesTest.getPackedPropertiesSum(tokenId3);
    const structSum = await nftPropertiesTest.getStructPropertiesSum(tokenId4);
    const structArraySum = await nftPropertiesTest.getStructArrayPropertiesSum(tokenId5);
    const packedArrayStructSum = await nftPropertiesTest.getPackedArrayStructSum(tokenId6);
    
    // All sums should equal 136 (sum of 1..16)
    const expectedSum = BigInt(136);
    expect(individualSum).to.equal(expectedSum, "Individual properties sum incorrect");
    expect(arraySum).to.equal(expectedSum, "Array properties sum incorrect");
    expect(bytes32Sum).to.equal(expectedSum, "Packed bytes32 properties sum incorrect");
    expect(structSum).to.equal(expectedSum, "Struct properties sum incorrect");
    expect(structArraySum).to.equal(expectedSum, "Struct with array properties sum incorrect");
    expect(packedArrayStructSum).to.equal(expectedSum, "Packed array struct sum incorrect");
    
    // Log gas usage for all approaches
    console.log("NFT MINTING GAS COSTS COMPARISON\n" +
                "------------------------------");
    console.log(`Individual mappings:     ${individualGas} gas`);
    console.log(`Array in mapping:        ${arrayGas} gas`);
    console.log(`Packed bytes32:          ${bytes32Gas} gas`);
    console.log(`Packed struct:           ${structGas} gas`);
    console.log(`Struct with array:       ${structArrayGas} gas`);
    console.log(`uint32 + uint16[14]:     ${packedArrayStructGas} gas`);
    
    // Calculate relative gas costs (using bytes32 as baseline)
    const getPercentage = (gas: bigint, baseline: bigint) => {
      return Math.round(Number((gas * BigInt(100)) / baseline));
    };
    
    // Print results in markdown table format
    console.log("| Storage Pattern | Gas Used | vs. bytes32 |");
    console.log("|-----------------|-----------|------------|");
    console.log(`| 1. bytes32 packed in mapping | ${bytes32Gas} | 100% |`);
    console.log(`| 2. Struct with packed uint16 fields | ${structGas} | ${getPercentage(structGas, bytes32Gas)}% |`);
    console.log(`| 3. uint16[16] array in mapping | ${arrayGas} | ${getPercentage(arrayGas, bytes32Gas)}% |`);
    console.log(`| 4. uint32 + uint16[14] within struct | ${packedArrayStructGas} | ${getPercentage(packedArrayStructGas, bytes32Gas)}% |`);
    console.log(`| 5. uint16[16] within struct | ${structArrayGas} | ${getPercentage(structArrayGas, bytes32Gas)}% |`);
    console.log(`| 6. 16 separate uint16 mappings | ${individualGas} | ${getPercentage(individualGas, bytes32Gas)}% |`);
  });
});
