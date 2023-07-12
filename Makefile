
.PHONY: fmt
fmt:
	isort pyfhevm/*.py
	black pyfhevm/*.py
