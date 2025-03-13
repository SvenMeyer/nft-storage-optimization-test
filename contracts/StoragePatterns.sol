// SPDX-License-Identifier: MIT
// Use specific version 0.8.28 with via-ir for optimization
pragma solidity >=0.8.28;

contract StoragePatterns {
    // This contract simulates storing properties for NFTs on-chain
    // We're not implementing the full ERC-721 standard, just the property storage patterns
    
    // Track the total number of "NFTs" minted
    uint256 public totalMinted;
    
    // ===== APPROACH 1: Individual Properties =====
    // Each NFT has 16 separate uint16 properties (separate variables)
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

    // ===== APPROACH 2: Array Properties =====
    // Each NFT has an array of 16 uint16 properties
    mapping(uint256 => uint16[16]) public nftArrayProperties;
    
    // ===== APPROACH 3: Packed bytes32 Properties =====
    // Each NFT has all 16 properties packed into a single bytes32
    mapping(uint256 => bytes32) public nftPackedProperties;
    
    // ===== APPROACH 4: Struct Properties =====
    // Each NFT has a struct with 16 packed uint16 properties
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
    mapping(uint256 => NFTProperties) public nftStructProperties;
    
    // ===== APPROACH 5: Struct with Array Properties =====
    // Each NFT has a struct containing an array of 16 uint16 properties
    struct NFTArrayStruct {
        uint16[16] properties;
        uint16 dummy; // We need this dummy variable to make the struct eligible for a public getter
    }
    mapping(uint256 => NFTArrayStruct) public nftStructWithArrayProperties;
    
    // ===== APPROACH 6: Packed Struct with uint32 + uint16[14] =====
    // This tests if the compiler can pack a small array with other variables in a struct
    // Theoretically, uint32(4 bytes) + uint16[14](28 bytes) = 32 bytes = 1 slot
    struct PackedArrayStruct {
        uint32 mainProperty;   // 4 bytes
        uint16[14] properties; // 14 * 2 bytes = 28 bytes
    }
    mapping(uint256 => PackedArrayStruct) public nftPackedArrayProperties;
    
    // =====  MINT FUNCTIONS (SIMULATE NFT MINTING WITH PROPERTIES) =====
    
    // Mint an NFT with individual properties
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
    
    // Mint an NFT with array properties
    function mintWithArrayProperties(uint16[16] memory properties) public returns (uint256) {
        uint256 tokenId = totalMinted++;
        
        for (uint256 i = 0; i < 16; i++) {
            nftArrayProperties[tokenId][i] = properties[i];
        }
        
        return tokenId;
    }
    
    // Mint an NFT with packed bytes32 properties
    function mintWithPackedProperties(uint16[16] memory properties) public returns (uint256) {
        uint256 tokenId = totalMinted++;
        
        bytes32 packed = packIntoBytes32(properties);
        nftPackedProperties[tokenId] = packed;
        
        return tokenId;
    }
    
    // Mint an NFT with struct properties
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
    
    // Mint an NFT with struct containing array properties
    function mintWithStructArrayProperties(uint16[16] memory properties) public returns (uint256) {
        uint256 tokenId = totalMinted++;
        
        NFTArrayStruct memory props;
        
        for (uint256 i = 0; i < 16; i++) {
            props.properties[i] = properties[i];
        }
        props.dummy = 100; // Set dummy value to a constant
        
        nftStructWithArrayProperties[tokenId] = props;
        
        return tokenId;
    }
    
    // Mint an NFT with packed struct containing uint32 + uint16[14] array
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
    
    // ===== HELPER FUNCTIONS =====
    
    // Helper to pack 16 uint16 values into a single bytes32
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
    
    // Helper to unpack bytes32 into 16 uint16 values
    function unpackBytes32(bytes32 packed) public pure returns (uint16[16] memory) {
        uint16[16] memory result;
        uint256 packedVal = uint256(packed);
        
        result[0] = uint16(packedVal);
        result[1] = uint16(packedVal >> 16);
        result[2] = uint16(packedVal >> 32);
        result[3] = uint16(packedVal >> 48);
        result[4] = uint16(packedVal >> 64);
        result[5] = uint16(packedVal >> 80);
        result[6] = uint16(packedVal >> 96);
        result[7] = uint16(packedVal >> 112);
        result[8] = uint16(packedVal >> 128);
        result[9] = uint16(packedVal >> 144);
        result[10] = uint16(packedVal >> 160);
        result[11] = uint16(packedVal >> 176);
        result[12] = uint16(packedVal >> 192);
        result[13] = uint16(packedVal >> 208);
        result[14] = uint16(packedVal >> 224);
        result[15] = uint16(packedVal >> 240);
        
        return result;
    }
    
    // Get sum for individual properties (verification)
    function getIndividualPropertiesSum(uint256 tokenId) public view returns (uint256) {
        return uint256(nftProperty1[tokenId]) + nftProperty2[tokenId] + nftProperty3[tokenId] + 
               nftProperty4[tokenId] + nftProperty5[tokenId] + nftProperty6[tokenId] + 
               nftProperty7[tokenId] + nftProperty8[tokenId] + nftProperty9[tokenId] + 
               nftProperty10[tokenId] + nftProperty11[tokenId] + nftProperty12[tokenId] + 
               nftProperty13[tokenId] + nftProperty14[tokenId] + nftProperty15[tokenId] + 
               nftProperty16[tokenId];
    }
    
    // Get sum for array properties (verification)
    function getArrayPropertiesSum(uint256 tokenId) public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 16; i++) {
            sum += nftArrayProperties[tokenId][i];
        }
        return sum;
    }
    
    // Get sum for struct properties (verification)
    function getStructPropertiesSum(uint256 tokenId) public view returns (uint256) {
        NFTProperties memory props = nftStructProperties[tokenId];
        return props.prop1 + props.prop2 + props.prop3 + props.prop4 + 
               props.prop5 + props.prop6 + props.prop7 + props.prop8 + 
               props.prop9 + props.prop10 + props.prop11 + props.prop12 + 
               props.prop13 + props.prop14 + props.prop15 + props.prop16;
    }
    
    // Get sum for struct with array properties (verification)
    function getStructArrayPropertiesSum(uint256 tokenId) public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 16; i++) {
            sum += nftStructWithArrayProperties[tokenId].properties[i];
        }
        return sum;
    }
    
    // Get the sum of the uint32 mainProperty and all uint16[14] array values
    function getPackedArrayStructSum(uint256 tokenId) public view returns (uint256) {
        uint256 sum = nftPackedArrayProperties[tokenId].mainProperty; // Add the uint32
        
        for (uint256 i = 0; i < 14; i++) {
            sum += nftPackedArrayProperties[tokenId].properties[i]; // Add all array values
        }
        
        return sum;
    }
    
    // Get sum for packed properties (verification)
    function getPackedPropertiesSum(uint256 tokenId) public view returns (uint256) {
        uint16[16] memory unpacked = unpackBytes32(nftPackedProperties[tokenId]);
        uint256 sum = 0;
        for (uint256 i = 0; i < 16; i++) {
            sum += unpacked[i];
        }
        return sum;
    }
}
