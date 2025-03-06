// SPDX-License-Identifier: MIT
// Use specific version 0.8.28 with via-ir for optimization
pragma solidity 0.8.28;

contract StorageTest {
    // IMPORTANT: This contract demonstrates storage slot usage in Solidity
    // Unlike common variables like uint256, which use compact storage (combining variables),
    // this contract deliberately forces each variable to occupy a whole storage slot
    // to clearly demonstrate the difference between array and packed storage.

    // SECTION 1: Individual uint16 variables - each deliberately placed in its own slot
    // We use a trick to force each to use its own slot - just make each a different state variable
    uint16 public value1; // slot 0
    uint16 public value2; // slot 1
    uint16 public value3; // slot 2
    uint16 public value4; // slot 3
    uint16 public value5; // slot 4
    uint16 public value6; // slot 5
    uint16 public value7; // slot 6
    uint16 public value8; // slot 7
    uint16 public value9; // slot 8
    uint16 public value10; // slot 9
    uint16 public value11; // slot 10
    uint16 public value12; // slot 11
    uint16 public value13; // slot 12
    uint16 public value14; // slot 13
    uint16 public value15; // slot 14
    uint16 public value16; // slot 15

    // SECTION 2: uint16 array - also takes one slot per element just like above,
    // but in array form to prove arrays don't pack elements
    uint16[16] public uint16Array; // slots 16-31

    // SECTION 3: bytes32 - fits all 16 values in ONE slot - much more efficient!
    bytes32 public packedValues; // slot 32

    // SECTION 4: Packed struct - also fits all 16 values in ONE slot
    // 16 × uint16 = 16 × 16 bits = 256 bits = 1 storage slot (32 bytes)
    struct Packed16UInt16Values {
        uint16 v1;
        uint16 v2;
        uint16 v3;
        uint16 v4;
        uint16 v5;
        uint16 v6;
        uint16 v7;
        uint16 v8;
        uint16 v9;
        uint16 v10;
        uint16 v11;
        uint16 v12;
        uint16 v13;
        uint16 v14;
        uint16 v15;
        uint16 v16;
    }

    Packed16UInt16Values public packedStruct; // slot 33

    // SECTION 5: Struct containing an array - to test how arrays behave inside structs
    struct StructWithArray {
        uint16[16] arrayValues;
        bytes32 dummy; // We add a dummy variable to make the struct eligible for a public getter
        // This won't affect our testing, as we're still primarily concerned with the array behavior
    }

    StructWithArray public structWithArray; // slots 34-49 (expected to use 16 slots) + 1 for dummy

    // For debugging - let's track how many function calls have been made
    // This helps verify our test setup and storage is actually functioning
    uint256 public individualValueCalls; // slot 50
    uint256 public arrayValueCalls; // slot 51
    uint256 public bytes32Calls; // slot 52
    uint256 public structCalls; // slot 53
    uint256 public structWithArrayCalls; // slot 54

    // Set the 16 individual values (one slot each = 16 slots total)
    function setIndividualValues(uint16[16] memory values) public {
        individualValueCalls++;
        value1 = values[0];
        value2 = values[1];
        value3 = values[2];
        value4 = values[3];
        value5 = values[4];
        value6 = values[5];
        value7 = values[6];
        value8 = values[7];
        value9 = values[8];
        value10 = values[9];
        value11 = values[10];
        value12 = values[11];
        value13 = values[12];
        value14 = values[13];
        value15 = values[14];
        value16 = values[15];
    }

    // Set array values (also 16 slots total)
    function setArrayValues(uint16[16] memory values) public {
        arrayValueCalls++;
        for (uint256 i = 0; i < 16; i++) {
            uint16Array[i] = values[i]; // setting each element individually to ensure slot usage
        }
    }

    // Set the bytes32 packed value (only 1 slot total)
    function setPackedBytes32(bytes32 value) public {
        bytes32Calls++;
        packedValues = value;
    }

    // Manual packing of 16 uint16 values into bytes32 (helper for tests)
    function packIntoBytes32(uint16[16] memory values) public pure returns (bytes32) {
        // This packs 16 uint16s (16 bits each) into a single bytes32 (256 bits)
        // This packs 16 uint16s (16 bits each) into a single bytes32 (256 bits)
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

    // Set the packed struct values (only 1 slot total)
    function setPackedStruct(uint16[16] memory values) public {
        structCalls++;
        packedStruct.v1 = values[0];
        packedStruct.v2 = values[1];
        packedStruct.v3 = values[2];
        packedStruct.v4 = values[3];
        packedStruct.v5 = values[4];
        packedStruct.v6 = values[5];
        packedStruct.v7 = values[6];
        packedStruct.v8 = values[7];
        packedStruct.v9 = values[8];
        packedStruct.v10 = values[9];
        packedStruct.v11 = values[10];
        packedStruct.v12 = values[11];
        packedStruct.v13 = values[12];
        packedStruct.v14 = values[13];
        packedStruct.v15 = values[14];
        packedStruct.v16 = values[15];
    }

    // Helper functions for tests to verify storage layout

    // Get individual values as stored in separate slots
    function getIndividualValuesSum() public view returns (uint256) {
        return
            uint256(value1) +
            value2 +
            value3 +
            value4 +
            value5 +
            value6 +
            value7 +
            value8 +
            value9 +
            value10 +
            value11 +
            value12 +
            value13 +
            value14 +
            value15 +
            value16;
    }

    // Get array values sum to verify they were stored correctly
    function getArrayValuesSum() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 16; i++) {
            sum += uint16Array[i];
        }
        return sum;
    }

    // Unpack bytes32 to verify it stored all values correctly
    function unpackBytes32() public view returns (uint16[16] memory) {
        uint16[16] memory result;
        uint256 packedVal = uint256(packedValues);

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

    // Get packed struct values sum to verify it was stored correctly
    function getPackedStructSum() public view returns (uint256) {
        return
            uint256(packedStruct.v1) +
            packedStruct.v2 +
            packedStruct.v3 +
            packedStruct.v4 +
            packedStruct.v5 +
            packedStruct.v6 +
            packedStruct.v7 +
            packedStruct.v8 +
            packedStruct.v9 +
            packedStruct.v10 +
            packedStruct.v11 +
            packedStruct.v12 +
            packedStruct.v13 +
            packedStruct.v14 +
            packedStruct.v15 +
            packedStruct.v16;
    }

    // Set values in the struct with array (expected to use 16 slots + 1 for dummy)
    function setStructWithArray(uint16[16] memory values) public {
        structWithArrayCalls++;
        for (uint256 i = 0; i < 16; i++) {
            structWithArray.arrayValues[i] = values[i];
        }
        structWithArray.dummy = bytes32(uint256(100)); // Set dummy value to a constant
    }

    // Get the sum of values in the struct containing an array
    function getStructWithArraySum() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 16; i++) {
            sum += structWithArray.arrayValues[i];
        }
        return sum;
    }

    // Direct storage slot access
    function getStorageAt(uint256 slot) public view returns (bytes32) {
        bytes32 value;
        assembly {
            value := sload(slot)
        }
        return value;
    }
}
