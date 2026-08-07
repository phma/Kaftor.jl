# Kaftor
Kaftor is a keyed affine transform. It is a sort of whole-message cipher, but being affine, it is not designed to keep information completely secret, as it does not withstand differential or linear cryptanalysis. Rather, it may be useful as part of multiparty communication protocols or other cryptographic protocols.


# Features
A round consists of three operations:

1. In the `jumble` operation, bytes whose indices (starting at 2) are multiplicative inverses mod a prime affect each other.
2. The `shufflePairs` operation takes bytes whose indices (starting at 0) differ by one bit, the bit depending on the round number, and rearranges them in one of 256 ways depending on a key byte, flipping from 4 to 12 bits. This provides confusion.
3. The `mix3Parts` operation splits the message or block in three equal parts and mixes them linearly. Each bit affects all bits in the other two bytes. This provides diffusion. The number of rounds in Kaftor increases logarithmically with message size so that diffusion spreads to the entire message.

Given messages `a`, `b`, `c`, and `d` such that `d==a⊻b⊻c`, and a key `k`, `e(d,k)==e(a,k)⊻e(b,k)⊻e(c,k)`.

The key schedule is affine; it consists of running the key through an LFSR, then exclusive-oring it with the Thue-Morse sequence stretched by the key length, so that a key `aa` is different from a key `a`, where `a` is any string.

# Julia
This is a Julia implementation. I'm planning to add another implementation, probably in Rust, in the same repo, and make both reference implementations.

In the project directory, run `julia --project` at the shell prompt, then in Julia run `using Kaftor`. You probably want `export JULIA_NUM_THREADS=auto` in your `.profile`, or to run `julia --project -t auto`, as the algorithms run faster on big inputs when multithreaded.

# Test vectors
Test vectors are in `test/src/test.jl`, which is called from `test/runtests.jl`. To run them, type `]` to enter Pkg mode, then `test`.
