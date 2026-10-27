#///////////////////////////////////////////
#// coverage-exclusions-rv32imc.do
#//
#// Written: David_Harris@hmc.edu 26 October 2026
#//
#// Purpose: Set of exclusions from coverage for the rv32imc configuration
#//          For example, signals hardwired to 0 should not be checked for toggle coverage
#//
#// A component of the CORE-V-WALLY configurable RISC-V project.
#// https://github.com/openhwfoundation/cvw
#//
#// Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University
#//
#// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#//
#// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file
#// except in compliance with the License, or, at your option, the Apache License version 2.0. You
#// may obtain a copy of the License at
#//
#// https://solderpad.org/licenses/SHL-2.1/
#//
#// Unless required by applicable law or agreed to in writing, any work distributed under the
#// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
#// either express or implied. See the License for the specific language governing permissions
#// and limitations under the License.
#////////////////////////////////////////////////////////////////////////////////////////////////

# This file should be a last resort.  It's preferable to put
# // coverage off
# statements inline with the code whenever possible.

# sim/Makefile (QuestaCodeCoverage) applies this file in Coverage View mode to the merged database, whose
# top scope is /core (wally-run.do saves /testbench/dut/core).  Applying it there, rather than in each
# simulation, matters: with Questa 2023.4, -fecexprrow/-feccondrow exclude single rows only in the form
#   coverage exclude -scope <scope> -fecexprrow <line> <row> [<row>|<row>-<row>] ...
# Combined with "-linerange <line> -item e 1" the row list is read as a line number and the whole expression
# is excluded instead.  Row lists are space separated; "2,4" excludes row 2 only.  A bare -linerange also
# excludes the FSM states and transitions Questa reports on that line, so name the items to exclude.
# Exclude only rows that cannot be reached, so that losing a reachable row shows up in the report.

set WALLY $::env(WALLY)
set SRC ${WALLY}/src

# a hack to describe coverage exclusions without hardcoding linenumbers:
do ${WALLY}/sim/questa/GetLineNum.do
