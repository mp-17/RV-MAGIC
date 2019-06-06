# RV-MAGIC
This is the special project of 2019 for the course Integrated Systems Architecture, held by Prof. Masera and Prof. Martina at Politecnico di Torino, designed by [@mksoc](https://github.com/mksoc), [@StMiky](https://github.com/StMiky), [@Alexey95](https://github.com/Alexey95) and [@mp-17](https://github.com/mp-17).

RV-MAGIC is a basic core implementing the RISC-V RV32I ISA written in SystemVerilog, featuring a 5-stage pipeline with instruction forwarding capabilities.

## Unsupported instructions
Due to limited time and no interest in supporting an operating system, some instruction were not implemented and are thus not supported, specifically:
- FENCE
- FENCE.I
- ECALL
- EBREAK
- CSRRW
- CSRRS
- CSRRC
- CSRRWI
- CSRRSI
- CSRRCI

We are aware that these limitations reduce the number of use cases for this core, and we cannot guarantee on the complete correctness of the project, which anyway has proven a very good exercise to get some hands-on experience on processor design. 
