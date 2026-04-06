# Makefile for running Ruby code quality tools over a given path (default: current directory).
# Provides targets for rubocop (auto-correct), flog, flay, reek, and a composite full_check.
FILE_PATH ?= .

rubocop:
	rubocop $(FILE_PATH) -A

flog:
	flog $(FILE_PATH)

flay:
	flay $(FILE_PATH)

reek:
	reek $(FILE_PATH)

full_check: rubocop flay reek flog
