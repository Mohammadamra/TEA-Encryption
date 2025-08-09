# TEA Encryption — Verilog Implementation

This project implements the **Tiny Encryption Algorithm (TEA)** in **Verilog HDL**, providing a lightweight yet secure encryption method suitable for hardware applications.

---

## Introduction to TEA

The **Tiny Encryption Algorithm (TEA)** is a simple, efficient, and compact block cipher designed by David Wheeler and Roger Needham in 1994. It operates on **64-bit blocks** of plaintext using a **128-bit key**, performing **64 Feistel rounds** (often implemented as 32 iterations of two half-rounds).  

TEA is known for:

- **Simplicity** — easy to implement in hardware and software.
- **Small footprint** — ideal for embedded and resource-constrained systems.
- **Speed** — efficient in terms of both execution and memory usage.
- **Security** — provides a good balance between diffusion and confusion.

### Core Operation
TEA splits the plaintext into two 32-bit halves (`left` and `right`). Each round updates one half using:
- Modular addition
- XOR operations
- Bitwise shifts
- Predefined constants (`delta`)

The key schedule uses four 32-bit segments (`key1`–`key4`) derived from the 128-bit key.

---

## Verilog Implementation Overview

The Verilog implementation in this project consists of **five main parts**:

1. **Key Expansion**  
   - Performed via direct segmentation of the 128-bit key into four 32-bit parts.
   - Added an **extra variable `mix`** to enhance diffusion by introducing additional XOR operations with key segments.

2. **Plaintext Segmentation**  
   - The 64-bit plaintext is split into `left` and `right` halves.
   - The `mix` variable is introduced early by XORing it with both halves for later use in the round function.

3. **Round Function (FSM Controlled)**  
   - Implements the TEA round operations using a **Finite State Machine**.
   - Handles 32 iterations (64 half-rounds) of encryption.
   - Incorporates `mix` in future work for additional diffusion/confusion.

4. **Top-Level Module**  
   - Integrates all submodules (Key Expansion, Segmentation, Round Function) into a complete encryption system.

5. **Testbench**  
   - Provides simulation and verification of the design.
   - Validates correctness against a known TEA C implementation.

---

## Simulation Results

### Initial Clock Cycles

<img width="696" height="505" alt="one" src="https://github.com/user-attachments/assets/7acd91b6-0acd-4bd6-a06e-b5cca573415b" />

In the first few clock cycles:
- The plaintext is correctly segmented into `left` and `right` halves.
- The keys are segmented into `key1`–`key4`.
- The FSM states in the round function module transition as expected.
- Round operations start executing according to TEA's schedule.

---

### Final Clock Cycle (Encryption Complete)

<img width="1829" height="500" alt="image" src="https://github.com/user-attachments/assets/efa1c497-5389-424c-aefb-ffc7cf24202f" />

In the last clock cycle:
- The `done` signal is asserted high, indicating encryption completion.
- The `left_out` and `right_out` registers hold the final cipher halves.
- The concatenated ciphertext is available at the top module output.

---

### Verification Against C Implementation

<img width="441" height="107" alt="image" src="https://github.com/user-attachments/assets/ef30aa93-0bb8-4d58-addc-fe2e288e9c56" />

Here, the Verilog output is **identical** to that produced by the original TEA implementation in C, confirming functional correctness.

---

## Future Work

- Integrate the `mix` variable into the round function for measurable improvement in **diffusion** and **confusion**.
- Implement decryption mode.
- Explore hardware optimizations for higher clock frequencies.
- Add support for parameterized key sizes.

---

## References

- Wheeler, D. J., & Needham, R. M. (1994). **TEA, a Tiny Encryption Algorithm**.  
- TEA algorithm details: [Wikipedia](https://en.wikipedia.org/wiki/Tiny_Encryption_Algorithm)
- The PDF in the same repo called TEA-XTEA 
---

