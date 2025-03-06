# NFT On-Chain Property Storage Optimization

This document presents our findings from testing different approaches to storing multiple properties (uint16 values) for NFTs on-chain. We measured the gas costs associated with minting NFTs that have 16 uint16 properties, comparing various storage patterns.

## Overview of Test Results

| Storage Pattern                       | Gas Used | vs. bytes32 |
|---------------------------------------|----------|------------:|
| 1. bytes32 packed in mapping          | 53,472   | 100%        |
| 2. Struct with packed uint16 fields   | 54,900   | 102%        |
| 3. uint16[16] array in mapping        | 61,112   | 114%        |
| 4. uint32 + uint16[14] within struct  | 79,939   | 149%        |
| 5. uint16[16] within struct           | 80,793   | 151%        |
| 6. 16 separate uint16 mappings        | 402,902  | 754%        |

## Storage Patterns in Detail

### 1. bytes32 packed in mapping (53,472 gas, 100% baseline)

All 16 properties for each NFT are packed into a single bytes32 value stored in a mapping. This is the most gas-efficient approach.

```solidity
// Each NFT has all 16 properties packed into a single bytes32
mapping(uint256 => bytes32) public nftPackedProperties;

// Helper function to pack 16 uint16 values into a bytes32
function packIntoBytes32(uint16[16] memory values) public pure returns (bytes32) {
    uint256 packedVal = uint256(values[0]);
    packedVal |= uint256(values[1]) << 16;
    packedVal |= uint256(values[2]) << 32;
    packedVal |= uint256(values[3]) << 48;
    packedVal |= uint256(values[4]) << 64;
    packedVal |= uint256(values[5]) << 80;
    packedVal |= uint256(values[6]) << 96;
    packedVal |= uint256(values[7]) << 112;
    packedVal |= uint256(values[8]) << 128;
    packedVal |= uint256(values[9]) << 144;
    packedVal |= uint256(values[10]) << 160;
    packedVal |= uint256(values[11]) << 176;
    packedVal |= uint256(values[12]) << 192;
    packedVal |= uint256(values[13]) << 208;
    packedVal |= uint256(values[14]) << 224;
    packedVal |= uint256(values[15]) << 240;
    return bytes32(packedVal);
}

// Mint function for packed properties
function mintWithPackedProperties(uint16[16] memory properties) public returns (uint256) {
    uint256 tokenId = totalMinted++;
    
    bytes32 packed = packIntoBytes32(properties);
    nftPackedProperties[tokenId] = packed;
    
    return tokenId;
}

// Helper to unpack and get a property at a specific index
function getPackedProperty(uint256 tokenId, uint8 index) public view returns (uint16) {
    require(index < 16, "Index out of bounds");
    bytes32 packed = nftPackedProperties[tokenId];
    return uint16(uint256(packed) >> (index * 16));
}
```

### 2. Struct with packed uint16 fields (54,900 gas, 102%)

A struct containing 16 uint16 fields, all packed into a single storage slot, stored in a mapping. This approach is almost as efficient as the bytes32 approach.

```solidity
// Struct with 16 packed uint16 properties
struct NFTProperties {
    uint16 prop1;
    uint16 prop2;
    uint16 prop3;
    uint16 prop4;
    uint16 prop5;
    uint16 prop6;
    uint16 prop7;
    uint16 prop8;
    uint16 prop9;
    uint16 prop10;
    uint16 prop11;
    uint16 prop12;
    uint16 prop13;
    uint16 prop14;
    uint16 prop15;
    uint16 prop16;
}

// Mapping from token ID to properties struct
mapping(uint256 => NFTProperties) public nftStructProperties;

// Mint function for struct properties
function mintWithStructProperties(uint16[16] memory properties) public returns (uint256) {
    uint256 tokenId = totalMinted++;
    
    NFTProperties memory props = NFTProperties({
        prop1: properties[0],
        prop2: properties[1],
        prop3: properties[2],
        prop4: properties[3],
        prop5: properties[4],
        prop6: properties[5],
        prop7: properties[6],
        prop8: properties[7],
        prop9: properties[8],
        prop10: properties[9],
        prop11: properties[10],
        prop12: properties[11],
        prop13: properties[12],
        prop14: properties[13],
        prop15: properties[14],
        prop16: properties[15]
    });
    
    nftStructProperties[tokenId] = props;
    
    return tokenId;
}
```

### 3. uint16[16] array in mapping (61,112 gas, 114%)

A fixed-size array of 16 uint16 values stored directly in a mapping. This approach uses 16 storage slots but has better gas efficiency than expected.

```solidity
// Each NFT has an array of 16 uint16 properties
mapping(uint256 => uint16[16]) public nftArrayProperties;

// Mint function for array properties
function mintWithArrayProperties(uint16[16] memory properties) public returns (uint256) {
    uint256 tokenId = totalMinted++;
    
    for (uint256 i = 0; i < 16; i++) {
        nftArrayProperties[tokenId][i] = properties[i];
    }
    
    return tokenId;
}
```

### 4. uint32 + uint16[14] within struct (79,939 gas, 149%)

A struct containing a uint32 field and a fixed-size array of 14 uint16 values, stored in a mapping. This tests whether the Solidity compiler can pack the array elements with other struct fields, since theoretically uint32 (4 bytes) + uint16[14] (28 bytes) = 32 bytes = 1 storage slot.

```solidity
// Struct with uint32 + uint16[14], theoretically fitting in a single slot
struct PackedArrayStruct {
    uint32 mainProperty;   // 4 bytes
    uint16[14] properties; // 14 * 2 bytes = 28 bytes
}

// Mapping from token ID to packed array struct
mapping(uint256 => PackedArrayStruct) public nftPackedArrayProperties;

// Mint function for struct with packed array
function mintWithPackedArrayStruct(uint16[16] memory properties) public returns (uint256) {
    uint256 tokenId = totalMinted++;
    
    PackedArrayStruct memory props;
    props.mainProperty = uint32(properties[0]) + uint32(properties[1]); // Combined first two values into uint32
    
    for (uint256 i = 0; i < 14; i++) {
        props.properties[i] = properties[i+2]; // Use the remaining 14 values
    }
    
    nftPackedArrayProperties[tokenId] = props;
    
    return tokenId;
}
```

### 5. uint16[16] within struct (80,793 gas, 151%)

A struct containing a fixed-size array of 16 uint16 values, stored in a mapping. This approach introduces significant overhead compared to using an array directly.

```solidity
// Struct containing an array of 16 uint16 properties
struct NFTArrayStruct {
    uint16[16] properties;
    uint16 dummy; // Required for public getter to work correctly
}

// Mapping from token ID to struct with array
mapping(uint256 => NFTArrayStruct) public nftStructWithArrayProperties;

// Mint function for struct with array properties
function mintWithStructArrayProperties(uint16[16] memory properties) public returns (uint256) {
    uint256 tokenId = totalMinted++;
    
    NFTArrayStruct memory props;
    for (uint256 i = 0; i < 16; i++) {
        props.properties[i] = properties[i];
    }
    props.dummy = 100; // Set dummy value
    
    nftStructWithArrayProperties[tokenId] = props;
    
    return tokenId;
}
```

### 6. 16 separate uint16 mappings (402,902 gas, 754%)

Using 16 separate mappings, one for each property. This is by far the most expensive approach due to the overhead of accessing multiple storage slots.

```solidity
// Each NFT has 16 separate uint16 properties (separate mappings)
mapping(uint256 => uint16) public nftProperty1;
mapping(uint256 => uint16) public nftProperty2;
mapping(uint256 => uint16) public nftProperty3;
mapping(uint256 => uint16) public nftProperty4;
mapping(uint256 => uint16) public nftProperty5;
mapping(uint256 => uint16) public nftProperty6;
mapping(uint256 => uint16) public nftProperty7;
mapping(uint256 => uint16) public nftProperty8;
mapping(uint256 => uint16) public nftProperty9;
mapping(uint256 => uint16) public nftProperty10;
mapping(uint256 => uint16) public nftProperty11;
mapping(uint256 => uint16) public nftProperty12;
mapping(uint256 => uint16) public nftProperty13;
mapping(uint256 => uint16) public nftProperty14;
mapping(uint256 => uint16) public nftProperty15;
mapping(uint256 => uint16) public nftProperty16;

// Mint function for individual mappings
function mintWithIndividualProperties(uint16[16] memory properties) public returns (uint256) {
    uint256 tokenId = totalMinted++;
    
    nftProperty1[tokenId] = properties[0];
    nftProperty2[tokenId] = properties[1];
    nftProperty3[tokenId] = properties[2];
    nftProperty4[tokenId] = properties[3];
    nftProperty5[tokenId] = properties[4];
    nftProperty6[tokenId] = properties[5];
    nftProperty7[tokenId] = properties[6];
    nftProperty8[tokenId] = properties[7];
    nftProperty9[tokenId] = properties[8];
    nftProperty10[tokenId] = properties[9];
    nftProperty11[tokenId] = properties[10];
    nftProperty12[tokenId] = properties[11];
    nftProperty13[tokenId] = properties[12];
    nftProperty14[tokenId] = properties[13];
    nftProperty15[tokenId] = properties[14];
    nftProperty16[tokenId] = properties[15];
    
    return tokenId;
}
```

## Key Gas Cost Differences

- **Individual mappings vs. Packed bytes32**: +349,430 gas (754% more expensive)
- **Array vs. Packed bytes32**: +7,640 gas (14% more expensive)
- **Struct vs. Packed bytes32**: +1,428 gas (2% more expensive)
- **uint32 + uint16[14] struct vs. bytes32**: +26,467 gas (49% more expensive)
- **uint32 + uint16[14] struct vs. Array**: +18,827 gas (31% more expensive)
- **uint16[16] struct vs. Array**: +19,681 gas (32% more expensive)

## Key Findings

1. **Dramatic Impact of Storage Pattern**: The choice of storage pattern for NFT properties can impact gas costs by over 750%.

2. **Best Option for NFTs**: Packed bytes32 is most efficient for storing multiple small values on NFTs, with packed structs a close second (only 2% more gas).

3. **Avoid Individual Mappings**: Using separate mappings for each property is extremely expensive (754% more gas than packed bytes32) due to the overhead of accessing multiple storage slots.

4. **Struct Containing Array Inefficiency**: Putting an array inside a struct adds a 32% gas cost penalty compared to a standalone array.

5. **Storage Hierarchy** (from most to least efficient):
   - Packed bytes32 in a mapping (most efficient)
   - Packed struct in a mapping (nearly as efficient)
   - Array in a mapping
   - Struct with uint32 + uint16[14] array (virtually the same as regular array in struct)
   - Struct with uint16[16] array
   - Individual mappings (extremely inefficient)
   
6. **Arrays in Structs Cannot Be Efficiently Packed**: Our attempt to pack a uint32 + uint16[14] array into a single storage slot showed that the Solidity compiler does not optimize array storage within structs. The gas cost (79,939) is almost identical to a struct with a full uint16[16] array (80,793), indicating that array elements in structs always occupy their own slots regardless of theoretical packing possibilities.

## Practical Application for NFT Projects

These findings suggest that for NFT projects storing multiple properties on-chain, developers should:

- Use packed bytes32 or packed structs for collections of small values
- Absolutely avoid using individual mappings for each property
- Avoid nesting arrays inside structs when possible
- Consider storage layout carefully during contract design, as it can dramatically impact gas costs for users

By optimizing property storage, NFT projects can significantly reduce minting costs for users and improve overall efficiency.
