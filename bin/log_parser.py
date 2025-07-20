#!/usr/bin/env python3
"""
UVM Log Parser - Extracts important information from UVM simulation logs
Located in bin/ directory, processes xsim.log from build/ directory
Parses RISC-V test logs and extracts:
- Test information
- Instructions generated
- Expected vs Actual comparisons
- Errors and warnings
- Test results

Usage:
  python parse_uvm_log.py                    # Processes ../build/xsim.log
  python parse_uvm_log.py /path/to/log.txt   # Processes specific log file
"""

import re
import sys
from datetime import datetime
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple

@dataclass
class InstructionInfo:
    """Information about a driven instruction"""
    name: str
    hex_data: str
    timestamp: str
    transaction_id: str

@dataclass
class ComparisonInfo:
    """Information about expected vs actual comparisons"""
    timestamp: str
    expected_instr: str
    actual_instr: str
    expected_addr: str
    actual_addr: str
    expected_data: str
    actual_data: str
    expected_write_en: str
    actual_write_en: str
    match: bool

@dataclass
class TestResult:
    """Overall test result information"""
    test_name: str
    status: str  # PASSED, FAILED, ERROR
    total_time: str
    uvm_info_count: int
    uvm_warning_count: int
    uvm_error_count: int
    uvm_fatal_count: int

class UVMLogParser:
    def __init__(self, log_content: str):
        self.log_content = log_content
        self.lines = log_content.split('\n')
        
    def parse(self) -> Dict:
        """Parse the entire log and return structured information"""
        return {
            'session_info': self._extract_session_info(),
            'test_info': self._extract_test_info(),
            'instructions': self._extract_instructions(),
            'comparisons': self._extract_comparisons(),
            'issues': self._extract_issues(),
            'test_result': self._extract_test_result(),
            'summary': self._extract_summary()
        }
    
    def _extract_session_info(self) -> Dict:
        """Extract session and system information"""
        session_info = {}
        
        # Extract basic session info
        for line in self.lines[:30]:  # Check first 30 lines
            if 'Start of session at:' in line:
                session_info['start_time'] = line.split('Start of session at:')[1].strip()
            elif 'Process ID' in line:
                session_info['process_id'] = line.split(':')[1].strip()
            elif 'Current directory' in line:
                session_info['working_directory'] = line.split(':')[1].strip()
            elif 'Running On' in line:
                session_info['hostname'] = line.split(':')[1].strip()
            elif 'Operating System' in line:
                session_info['os'] = line.split(':')[1].strip()
            elif 'Processor Detail' in line:
                session_info['processor'] = line.split(':')[1].strip()
                
        return session_info
    
    def _extract_test_info(self) -> Dict:
        """Extract test-specific information"""
        test_info = {}
        
        for line in self.lines:
            if 'Running test' in line:
                match = re.search(r'Running test (\w+)', line)
                if match:
                    test_info['test_name'] = match.group(1)
            elif 'UVM_TESTNAME=' in line:
                match = re.search(r'UVM_TESTNAME=(\w+)', line)
                if match:
                    test_info['test_class'] = match.group(1)
        
        return test_info
    
    def _extract_instructions(self) -> List[InstructionInfo]:
        """Extract all driven instructions"""
        instructions = []
        
        i = 0
        while i < len(self.lines):
            line = self.lines[i]
            if 'Driving instruction:' in line:
                # Extract instruction name
                match = re.search(r'Driving instruction: (\w+)', line)
                if match:
                    instr_name = match.group(1)
                    
                    # Extract timestamp
                    timestamp_match = re.search(r'@ (\d+):', line)
                    timestamp = timestamp_match.group(1) if timestamp_match else "unknown"
                    
                    # Look for instruction data in following lines
                    hex_data = "unknown"
                    transaction_id = "unknown"
                    
                    # Scan next 20 lines for instr_data
                    for j in range(i+1, min(i+21, len(self.lines))):
                        if 'instr_data' in self.lines[j] and "'h" in self.lines[j]:
                            hex_match = re.search(r"'h([0-9a-fA-F]+)", self.lines[j])
                            if hex_match:
                                hex_data = "0x" + hex_match.group(1)
                        elif '@' in self.lines[j] and 'req' in self.lines[j]:
                            trans_match = re.search(r'@(\d+)', self.lines[j])
                            if trans_match:
                                transaction_id = trans_match.group(1)
                    
                    instructions.append(InstructionInfo(
                        name=instr_name,
                        hex_data=hex_data,
                        timestamp=timestamp,
                        transaction_id=transaction_id
                    ))
            i += 1
        
        return instructions
    
    def _extract_comparisons(self) -> List[ComparisonInfo]:
        """Extract expected vs actual comparisons"""
        comparisons = []
        
        i = 0
        while i < len(self.lines):
            line = self.lines[i]
            if 'Expected instr =' in line:
                # Extract timestamp
                timestamp_match = re.search(r'@ (\d+):', line)
                timestamp = timestamp_match.group(1) if timestamp_match else "unknown"
                
                # Extract expected and actual instruction
                exp_match = re.search(r'Expected instr = (0x[0-9a-fA-F]+)', line)
                act_match = re.search(r'Actual instr = (0x[0-9a-fA-F]+)', line)
                
                expected_instr = exp_match.group(1) if exp_match else "unknown"
                actual_instr = act_match.group(1) if act_match else "unknown"
                
                # Look for other comparisons in next few lines
                expected_addr = actual_addr = "unknown"
                expected_data = actual_data = "unknown"
                expected_write_en = actual_write_en = "unknown"
                
                for j in range(i+1, min(i+5, len(self.lines))):
                    line_j = self.lines[j]
                    if 'Expected addr =' in line_j:
                        exp_addr_match = re.search(r'Expected addr = (0x[0-9a-fA-F]+)', line_j)
                        act_addr_match = re.search(r'Actual addr = (0x[0-9a-fA-F]+)', line_j)
                        expected_addr = exp_addr_match.group(1) if exp_addr_match else "unknown"
                        actual_addr = act_addr_match.group(1) if act_addr_match else "unknown"
                    elif 'Expected data =' in line_j:
                        exp_data_match = re.search(r'Expected data = (0x[0-9a-fA-F]+)', line_j)
                        act_data_match = re.search(r'Actual data = (0x[0-9a-fA-F]+)', line_j)
                        expected_data = exp_data_match.group(1) if exp_data_match else "unknown"
                        actual_data = act_data_match.group(1) if act_data_match else "unknown"
                    elif 'Expected write enable =' in line_j:
                        exp_we_match = re.search(r'Expected write enable = (\d+)', line_j)
                        act_we_match = re.search(r'Actual write enable = (\d+)', line_j)
                        expected_write_en = exp_we_match.group(1) if exp_we_match else "unknown"
                        actual_write_en = act_we_match.group(1) if act_we_match else "unknown"
                
                # Determine if values match
                match = (expected_instr == actual_instr and 
                        expected_addr == actual_addr and
                        expected_data == actual_data and
                        expected_write_en == actual_write_en)
                
                comparisons.append(ComparisonInfo(
                    timestamp=timestamp,
                    expected_instr=expected_instr,
                    actual_instr=actual_instr,
                    expected_addr=expected_addr,
                    actual_addr=actual_addr,
                    expected_data=expected_data,
                    actual_data=actual_data,
                    expected_write_en=expected_write_en,
                    actual_write_en=actual_write_en,
                    match=match
                ))
            i += 1
        
        return comparisons
    
    def _extract_issues(self) -> Dict:
        """Extract warnings, errors, and other issues"""
        issues = {
            'warnings': [],
            'errors': [],
            'fatals': [],
            'unknown_instructions': []
        }
        
        for line in self.lines:
            if 'UVM_WARNING' in line:
                issues['warnings'].append(line.strip())
            elif 'UVM_ERROR' in line:
                issues['errors'].append(line.strip())
            elif 'UVM_FATAL' in line:
                issues['fatals'].append(line.strip())
            elif 'Driving instruction: UNKNOWN' in line:
                # Extract timestamp and hex data for unknown instructions
                timestamp_match = re.search(r'@ (\d+):', line)
                timestamp = timestamp_match.group(1) if timestamp_match else "unknown"
                issues['unknown_instructions'].append({
                    'timestamp': timestamp,
                    'line': line.strip()
                })
        
        return issues
    
    def _extract_test_result(self) -> TestResult:
        """Extract overall test result"""
        test_name = "unknown"
        status = "UNKNOWN"
        total_time = "unknown"
        
        # Extract test name
        for line in self.lines:
            if 'Running test' in line:
                match = re.search(r'Running test (\w+)', line)
                if match:
                    test_name = match.group(1)
                    break
        
        # Determine status
        for line in self.lines:
            if 'TEST CASE PASSED' in line:
                status = "PASSED"
                break
            elif 'TEST CASE FAILED' in line:
                status = "FAILED"
                break
            elif 'UVM_ERROR' in line or 'UVM_FATAL' in line:
                status = "ERROR"
        
        # Extract timing info
        for line in self.lines:
            if '$finish called at time' in line:
                match = re.search(r'time : (\d+ \w+)', line)
                if match:
                    total_time = match.group(1)
                    break
        
        # Extract UVM report counts
        uvm_info = uvm_warning = uvm_error = uvm_fatal = 0
        for line in self.lines:
            if 'UVM_INFO :' in line:
                match = re.search(r'UVM_INFO :\s*(\d+)', line)
                if match:
                    uvm_info = int(match.group(1))
            elif 'UVM_WARNING :' in line:
                match = re.search(r'UVM_WARNING :\s*(\d+)', line)
                if match:
                    uvm_warning = int(match.group(1))
            elif 'UVM_ERROR :' in line:
                match = re.search(r'UVM_ERROR :\s*(\d+)', line)
                if match:
                    uvm_error = int(match.group(1))
            elif 'UVM_FATAL :' in line:
                match = re.search(r'UVM_FATAL :\s*(\d+)', line)
                if match:
                    uvm_fatal = int(match.group(1))
        
        return TestResult(
            test_name=test_name,
            status=status,
            total_time=total_time,
            uvm_info_count=uvm_info,
            uvm_warning_count=uvm_warning,
            uvm_error_count=uvm_error,
            uvm_fatal_count=uvm_fatal
        )
    
    def _extract_summary(self) -> Dict:
        """Extract summary information"""
        summary = {
            'total_instructions': 0,
            'unknown_instructions': 0,
            'comparisons_made': 0,
            'comparisons_passed': 0,
            'total_issues': 0
        }
        
        # Count instructions
        for line in self.lines:
            if 'Driving instruction:' in line:
                summary['total_instructions'] += 1
                if 'UNKNOWN' in line:
                    summary['unknown_instructions'] += 1
        
        # Count comparisons
        for line in self.lines:
            if 'Expected instr =' in line:
                summary['comparisons_made'] += 1
        
        # Count issues
        for line in self.lines:
            if any(x in line for x in ['UVM_WARNING', 'UVM_ERROR', 'UVM_FATAL']):
                summary['total_issues'] += 1
        
        return summary

def format_output(parsed_data: Dict) -> str:
    """Format parsed data into a readable report"""
    output = []
    
    # Header
    output.append("="*60)
    output.append("UVM SIMULATION LOG ANALYSIS REPORT")
    output.append("="*60)
    output.append("")
    
    # Test Information
    test_info = parsed_data['test_info']
    test_result = parsed_data['test_result']
    output.append("TEST INFORMATION:")
    output.append(f"  Test Name: {test_result.test_name}")
    output.append(f"  Test Class: {test_info.get('test_class', 'unknown')}")
    output.append(f"  Status: {test_result.status}")
    output.append(f"  Total Time: {test_result.total_time}")
    output.append("")
    
    # Summary
    summary = parsed_data['summary']
    output.append("SUMMARY:")
    output.append(f"  Total Instructions: {summary['total_instructions']}")
    output.append(f"  Unknown Instructions: {summary['unknown_instructions']}")
    output.append(f"  Comparisons Made: {summary['comparisons_made']}")
    output.append(f"  UVM Messages: INFO={test_result.uvm_info_count}, "
                 f"WARNING={test_result.uvm_warning_count}, "
                 f"ERROR={test_result.uvm_error_count}, "
                 f"FATAL={test_result.uvm_fatal_count}")
    output.append("")
    
    # Instructions Generated
    instructions = parsed_data['instructions']
    output.append("INSTRUCTIONS GENERATED:")
    if instructions:
        for i, instr in enumerate(instructions, 1):
            output.append(f"  {i}. {instr.name} ({instr.hex_data}) @ {instr.timestamp}ps")
    else:
        output.append("  No instructions found")
    output.append("")
    
    # Expected vs Actual Comparisons
    comparisons = parsed_data['comparisons']
    output.append("EXPECTED vs ACTUAL COMPARISONS:")
    if comparisons:
        for i, comp in enumerate(comparisons, 1):
            status = "✓ PASS" if comp.match else "✗ FAIL"
            output.append(f"  {i}. @ {comp.timestamp}ps - {status}")
            output.append(f"     Instruction: {comp.expected_instr} vs {comp.actual_instr}")
            output.append(f"     Address:     {comp.expected_addr} vs {comp.actual_addr}")
            output.append(f"     Data:        {comp.expected_data} vs {comp.actual_data}")
            output.append(f"     Write En:    {comp.expected_write_en} vs {comp.actual_write_en}")
    else:
        output.append("  No comparisons found")
    output.append("")
    
    # Issues Found
    issues = parsed_data['issues']
    output.append("ISSUES FOUND:")
    total_issues = (len(issues['warnings']) + len(issues['errors']) + 
                   len(issues['fatals']) + len(issues['unknown_instructions']))
    
    if total_issues > 0:
        if issues['unknown_instructions']:
            output.append(f"  Unknown Instructions ({len(issues['unknown_instructions'])}):")
            for unk in issues['unknown_instructions']:
                output.append(f"    @ {unk['timestamp']}ps")
        
        if issues['warnings']:
            output.append(f"  Warnings ({len(issues['warnings'])}):")
            for warning in issues['warnings']:
                output.append(f"    {warning}")
        
        if issues['errors']:
            output.append(f"  Errors ({len(issues['errors'])}):")
            for error in issues['errors']:
                output.append(f"    {error}")
        
        if issues['fatals']:
            output.append(f"  Fatal Errors ({len(issues['fatals'])}):")
            for fatal in issues['fatals']:
                output.append(f"    {fatal}")
    else:
        output.append("  No issues found")
    
    output.append("")
    output.append("="*60)
    
    return "\n".join(output)

def main():
    """Main function to process UVM log file"""
    import os
    
    # Default to xsim.log in build directory (relative to bin)
    if len(sys.argv) == 1:
        # Script is in bin, look for xsim.log in ../build/
        script_dir = os.path.dirname(os.path.abspath(__file__))
        log_file_path = os.path.join(script_dir, '..', 'build', 'xsim.log')
    elif len(sys.argv) == 2:
        log_file_path = sys.argv[1]
    else:
        print("Usage: python parse_uvm_log.py [log_file_path]")
        print("  If no path provided, looks for ../build/xsim.log")
        sys.exit(1)
    
    try:
        with open(log_file_path, 'r') as file:
            log_content = file.read()
        
        parser = UVMLogParser(log_content)
        parsed_data = parser.parse()
        
        report = format_output(parsed_data)
        print(report)
        
        # Save analysis to build directory
        script_dir = os.path.dirname(os.path.abspath(__file__))
        build_dir = os.path.join(script_dir, '..', 'build')
        output_file = os.path.join(build_dir, 'xsim_analysis.txt')
        
        try:
            with open(output_file, 'w') as f:
                f.write(report)
            print(f"\nDetailed analysis saved to: {output_file}")
        except Exception as e:
            print(f"\nNote: Could not save analysis file: {e}")
        
    except FileNotFoundError:
        print(f"Error: File '{log_file_path}' not found")
        print("Make sure xsim.log exists in the build directory")
        sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()