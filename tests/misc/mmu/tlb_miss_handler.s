# 
# Copyright 2015 Jeff Bush
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 


#
# Map the low 8 MB of physical address space repeating across the entire
# virtual address range, except the memory mapped registers at 0xffff0000,
# which are identity mapped.
#

					.globl tlb_miss_handler
tlb_miss_handler:	setcr s0, 11		# Save s0 in scratchpad
					setcr s1, 12        # Save s1
					getcr s0, 5			# Get fault virtual address

					# Is this in the device region (0xffff0000-)
					move s1, -1
					shl s1, s1, 16
					cmpgt_u s1, s0, s1
					btrue s1, map_device

					# Make lowaddress space repeat every 8MB
					shl s0, s0, 9
					shr s0, s0, 9

map_device:			setcr s0, 8			# Set physical address

					getcr s0, 5			# Get fault virtual address
					getcr s1, 3			# Get fault reason
					cmpeq_i s1, s1, 5	# Is ITLB miss?
					btrue s1, fill_itlb # If so, branch to update ITLB
fill_dltb:			setcr s0, 10        # Set virtual address for DTLB
					goto done
fill_itlb:			setcr s0, 9         # Set virtual address for ITLB
done:				getcr s0, 11        # Get saved s0 from scratchpad
					getcr s1, 12        # Get saved s1
					eret