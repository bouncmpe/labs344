# Wally Coremark Tests

This directory provides build and run scripts to execute the **Coremark benchmark** on the Wally RISC-V cores.  
It supports multiple RISC-V ISA configurations for both 32-bit and 64-bit variants.

## Running Tests

To build and run Coremark with a specific architecture:

```bash
make run ARCH=rv32gc
```

## Supported architectures

The following RISC-V ISA configurations are currently supported:

- rv32i_zicsr
- rv32im_zicsr
- rv32imc_zicsr
- rv32im_zicsr_zba_zbb_zbs
- rv32gc
- rv32gc_zba_zbb_zbs
- rv64i_zicsr
- rv64im_zicsr
- rv64imc_zicsr
- rv64im_zicsr_zba_zbb_zbs
- rv64gc
- rv64gc_zba_zbb_zbs

## Notes

- Benchmark results may differ across architectures due to instruction set extensions and optimization differences.