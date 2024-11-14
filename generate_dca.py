import os
import argparse
import itertools
from pathlib import *
from xml.dom import minidom
import xml.etree.ElementTree as XmlTree

def get_ip_parameter_value(ip_instance, parameter_name:str):
  parameter_value = None
  for parameter_xml in ip_instance.findall('parameter'):
    if parameter_xml.find('id').text==parameter_name:
      parameter_value = parameter_xml.find('value').text
      break
  assert parameter_value!=None, ip_instance
  return parameter_value
      
if __name__ == '__main__':
  # parse argument
  parser = argparse.ArgumentParser(description='Generate DCA ssw')
  parser.add_argument('-input', '-i', help='an input xml file')
  parser.add_argument('-output', '-o', help='output directory')
  args = parser.parse_args()
  
  assert args.input
  assert args.output
  
  input_path = Path(args.input).resolve()
  assert input_path.is_file(), input_path
  output_dir = Path(args.output).resolve()
  assert output_dir.is_dir(), output_dir
  
  xml_tree = XmlTree.parse(input_path)
  xml_root = xml_tree.getroot()
  assert len(xml_root)>=1, 'No available info'
  assert xml_root.tag=='rvx', xml_root.tag
  
  header_name = input_path.stem
  include_list = set()
  variable_list = []
  
  # analyze
  for ip_instance in xml_root.findall('ip_instance'):
    library_name = ip_instance.find('library_name').text
    ip_instance_name = ip_instance.find('name').text
    struct_name = library_name.title().replace('_','')+'HwInfo'
    variable_name = f'{ip_instance_name}_info'
    if library_name=='dca_matrix_mac':
      include_list.add('dca_matrix_hw.h')
      variable_list.append((library_name, ip_instance_name, struct_name, variable_name))
    elif library_name=='starc':
      include_list.add('starc.h')
      variable_list.append((library_name, ip_instance_name, struct_name, variable_name))
    elif library_name=='sram_xmi':
      pass
    elif library_name=='pact_dca':
      pass
    else:
      assert 0, library_name
    
  # header
  line_list = []
  line_list.append(f'#ifndef __{header_name.upper()}_H__')
  line_list.append(f'#define __{header_name.upper()}_H__')
  line_list.append('')
  line_list += [f'#include \"{x}\"' for x in include_list]
  line_list.append('')
  line_list += [f'extern {struct_name}* {variable_name};' for library_name, ip_instance_name, struct_name, variable_name in variable_list]
  line_list.append('')
  line_list.append('#endif')
  
  header_path = output_dir / f'{header_name}.h'
  header_path.write_text('\n'.join(line_list))
  
  # body
  include_list = []
  include_list.append(f'{header_name}.h')
  include_list.append('platform_info.h')
  include_list.append('ervp_malloc.h')
  include_list.append('ervp_mmio_util.h')
  
  line_list = []
  line_list += [f'#include \"{x}\"' for x in include_list]
  
  line_list.append('')
  line_list += [f'{struct_name}* {variable_name};' for library_name, ip_instance_name, struct_name, variable_name in variable_list]
  
  line_list.append('')
  line_list.append(f'static void __attribute__ ((constructor)) construct_{header_name}()')
  line_list.append('{')
  for ip_instance in xml_root.findall('ip_instance'):
    library_name = ip_instance.find('library_name').text
    ip_instance_name = ip_instance.find('name').text
    struct_name = library_name.title().replace('_','')+'HwInfo'
    variable_name = f'{ip_instance_name}_info'
    
    line_list.append(f'\t// {variable_name}')
    
    if library_name=='dca_matrix_mac':
      line_list.append(f'\t{variable_name} = malloc(sizeof({struct_name}));')
      line_list.append(f'\t{variable_name}->control_addr = (mmio_addr_t){ip_instance_name.upper()}_CONTROL_BASEADDR;')
      matrix_size_config = int(get_ip_parameter_value(ip_instance, 'MATRIX_SIZE_CONFIG'))
      num_row = matrix_size_config % 100
      num_col = ((int)(matrix_size_config/100)) % 100
      if num_col==0:
        num_col = num_row
      member_assign_list = []
      member_assign_list.append(('num_row',num_row))
      member_assign_list.append(('num_col',num_col))
      for member_name, member_value in member_assign_list:
        line_list.append(f'\t{variable_name}->{member_name} = {member_value};')
    elif library_name=='starc':
      line_list.append(f'\t{variable_name} = malloc(sizeof({struct_name}));')
      line_list.append(f'\t{variable_name}->control_addr = (mmio_addr_t){ip_instance_name.upper()}_CONTROL_BASEADDR;')
      member_assign_list = []
      member_assign_list.append(('num_core_input', int(get_ip_parameter_value(ip_instance, 'NUM_CORE_INPUT'))))
      member_assign_list.append(('num_core_output', int(get_ip_parameter_value(ip_instance, 'NUM_CORE_OUTPUT'))))
      member_assign_list.append(('bw_weight', int(get_ip_parameter_value(ip_instance, 'BW_WEIGHT'))))
      for member_name, member_value in member_assign_list:
        line_list.append(f'\t{variable_name}->{member_name} = {member_value};')
    elif library_name=='sram_xmi':
      pass
    elif library_name=='pact_dca':
      pass
    else:
      assert 0, library_name
  line_list.append('};')
  
  line_list.append('')
  line_list.append(f'static void __attribute__ ((destructor)) destruct_{header_name}()')
  line_list.append('{')
  for library_name, ip_instance_name, struct_name, variable_name in variable_list:
    line_list.append(f'\tfree({variable_name});')
  line_list.append('};')
  
  body_path = output_dir / f'{header_name}.c'
  body_path.write_text('\n'.join(line_list))