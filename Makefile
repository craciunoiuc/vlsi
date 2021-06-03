
build: divider_circuit

divider_circuit: DataPath.v RegStorage.v ALU.v UC.v Divider.v CircuitTB.v
	iverilog DataPath.v RegStorage.v ALU.v UC.v Divider.v CircuitTB.v -o divider_circuit

run: divider_circuit
	./divider_circuit

clean:
	rm -f divider_circuit divider_tb.vcd

