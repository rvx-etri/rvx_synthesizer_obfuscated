## ****************************************************************************
## ****************************************************************************
## Copyright SoC Design Research Group, All rights reserved.    
## Electronics and Telecommunications Research Institute (ETRI)
##
## THESE DOCUMENTS CONTAIN CONFIDENTIAL INFORMATION AND KNOWLEDGE 
## WHICH IS THE PROPERTY OF ETRI. NO PART OF THIS PUBLICATION IS 
## TO BE USED FOR ANY OTHER PURPOSE, AND THESE ARE NOT TO BE 
## REPRODUCED, COPIED, DISCLOSED, TRANSMITTED, STORED IN A RETRIEVAL 
## SYSTEM OR TRANSLATED INTO ANY OTHER HUMAN OR COMPUTER LANGUAGE, 
## IN ANY FORM, BY ANY MEANS, IN WHOLE OR IN PART, WITHOUT THE 
## COMPLETE PRIOR WRITTEN PERMISSION OF ETRI.
## ****************************************************************************
## 2017-02
## Kyuseung Han (han@etri.re.kr)
## ****************************************************************************
## ****************************************************************************

import os

class VerilogGenerator:
  @staticmethod
  def gen_header_prologue(file_name):
    macro_name = '__%s_H__' % (os.path.split(file_name)[-1]).split('.')[0].upper()
    return '`ifndef %s\n`define %s' % (macro_name, macro_name)

  @staticmethod
  def gen_header_epilogue(file_name):
    return '`endif'

  @staticmethod
  def gen_value(value, format):
    assert type(value)==str, type(value)
    value_str = None
    if format=='dec':
      value_str = value
    elif format=='hex':
      value_str = '({0}\'h {1})'.format(32,value[2:])
    elif format=='str':
      value_str = '\"{0}\"'.format(value)
    elif format=='text':
      value_str = '{0}'.format(value)
    elif format=='exp':
      value = value.replace('$','`')
      value_str = '{0}'.format(value)
    elif format=='lang_verilog':
      value_str = '{0}'.format(value)
    elif format[0:5]=='lang_':
      pass
    else:
      assert 0, format
    return value_str

  @staticmethod
  def gen_define(name, value, format):
    assert type(value)==str, type(value)
    line = None
    if format=='bool':
      line = '`define {0}'.format(name)
      if value=='False':
        line = '//' + line
    else:
      value_str = VerilogGenerator.gen_value(value,format)
      if value_str:
        line = '`define {0} {1}'.format(name,value_str)
    return line

  @staticmethod
  def gen_short_comments(text):
    return '// %s' % text

  @staticmethod
  def use_define(name):
    return ('`%s' % (name))

  @staticmethod
  def gen_include(include_name):
    return '`include \"{0}.vh\"'.format(include_name)



