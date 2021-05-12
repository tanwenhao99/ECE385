/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"
#include "system.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

void KeyExpansionCore(unsigned char * key, unsigned char k)
{
	unsigned int* q = (unsigned int*)key;
	*q = (*q >> 8) | ((*q & 0xFF) << 24);
	for (int i = 0; i < 4; i++)
		key[i] = aes_sbox[key[i]];
	key[0] ^= Rcon[k] >> 24;
}

void KeyExpansion(unsigned char * key, unsigned char * expandedKeys)
{
	int i = 0;
	for (i = 0; i < 16; i++)
		expandedKeys[i] = key[i];
	int k = 1;
	unsigned char temp[4];
	while (i < 176) {
		for (int j = 0; j < 4; j++)
			temp[j] = expandedKeys[i + j - 4];
		if (i % 16 == 0)
			KeyExpansionCore(temp, k++);
		for (int j = 0; j < 4; j++) {
			expandedKeys[i] = expandedKeys[i - 16] ^ temp[j];
			i++;
		}
	}
}

void AddRoundKey(unsigned char * states, unsigned char * key)
{
	for (int i = 0; i < 16; i++)
		states[i] ^= key[i];
}

void SubBytes(unsigned char * states)
{
	for (int i = 0; i < 16; i++)
		states[i] = aes_sbox[states[i]];
}

void MixColumns(unsigned char * states)
{
	unsigned char temp[16];
	for (int i = 0; i < 4; i++) {
		temp[4 * i] = gf_mul[states[4 * i]][0] ^ gf_mul[states[4 * i + 1]][1] ^ states[4 * i + 2] ^ states[4 * i + 3];
		temp[4 * i + 1] = states[4 * i] ^ gf_mul[states[4 * i + 1]][0] ^ gf_mul[states[4 * i + 2]][1] ^ states[4 * i + 3];
		temp[4 * i + 2] = states[4 * i] ^ states[4 * i + 1] ^ gf_mul[states[4 * i + 2]][0] ^ gf_mul[states[4 * i + 3]][1];
		temp[4 * i + 3] = gf_mul[states[4 * i]][1] ^ states[4 * i + 1] ^ states[4 * i + 2] ^ gf_mul[states[4 * i + 3]][0];
	}
	for (int i = 0; i < 16; i++)
		states[i] = temp[i];
}

void ShiftRows(unsigned char * states)
{
	uchar temp[16];
	temp[0] = states[0];
	temp[1] = states[5];
	temp[2] = states[10];
	temp[3] = states[15];
	temp[4] = states[4];
	temp[5] = states[9];
	temp[6] = states[14];
	temp[7] = states[3];
	temp[8] = states[8];
	temp[9] = states[13];
	temp[10] = states[2];
	temp[11] = states[7];
	temp[12] = states[12];
	temp[13] = states[1];
	temp[14] = states[6];
	temp[15] = states[11];
	for (int i = 0; i < 16; i++)
		states[i] = temp[i];
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	// Implement this function
	unsigned char states[16];
	unsigned char init_key[16];
	for (int i = 0; i < 16; i++) {
		states[i] = charsToHex(msg_ascii[2 * i], msg_ascii[2 * i + 1]);
		init_key[i] = charsToHex(key_ascii[2 * i], key_ascii[2 * i + 1]);
	}
	for (int i = 0; i < 4; i++)
		AES_PTR[i] = (init_key[4 * i] << 24) + (init_key[4 * i + 1] << 16) + (init_key[4 * i + 2] << 8) + init_key[4 * i + 3];
	unsigned char expandedKeys[176];
	KeyExpansion(init_key, expandedKeys);
	AddRoundKey(states, expandedKeys);
	for (int i = 1; i < 10; i++) {
		SubBytes(states);
		ShiftRows(states);
		MixColumns(states);
		AddRoundKey(states, expandedKeys + i * 16);
	}
	SubBytes(states);
	ShiftRows(states);
	AddRoundKey(states, expandedKeys + 160);
	for (int i = 0; i < 4; i++) {
		msg_enc[i] = (states[4 * i] << 24) + (states[4 * i + 1] << 16) + (states[4 * i + 2] << 8) + states[4 * i + 3];
		key[i] = (init_key[4 * i] << 24) + (init_key[4 * i + 1] << 16) + (init_key[4 * i + 2] << 8) + init_key[4 * i + 3];
	}
}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
	AES_PTR[0] = key[0];
	AES_PTR[1] = key[1];
	AES_PTR[2] = key[2];
	AES_PTR[3] = key[3];
	AES_PTR[4] = msg_enc[0];
	AES_PTR[5] = msg_enc[1];
	AES_PTR[6] = msg_enc[2];
	AES_PTR[7] = msg_enc[3];
	AES_PTR[14] = 1;
	while (AES_PTR[15] == 0);
	msg_dec[0] = AES_PTR[8];
	msg_dec[1] = AES_PTR[9];
	msg_dec[2] = AES_PTR[10];
	msg_dec[3] = AES_PTR[11];
	AES_PTR[14] = 0;
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
