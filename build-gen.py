#!/usr/bin/env python

import time
import signal
import os

from enum import Enum

class identifier(Enum):
    SINGLE      = 1
    MULTI_BEGIN = 2
    MULTI_END   = 3

class read_state(Enum):
    SEARCH_FOR_ATTRIBUTE  = 1
    GET_SINGLE_LINE_VALUE = 2
    GET_MULTI_LINE_VALUE  = 3

#------------------------------------------------------------
def config_line_attribute_get(line):
    # remove leading and trailing whitespace characters
    striped = line.strip()

    try:
        # get first and last characters
        first = striped[0]
        last  = striped[len(striped) - 1]

        # when markers are found in correct place
        if first == '<' and last == '>':
            attribute = striped[1:len(striped) - 1]

            splited = attribute.split(':')

            # when separator is not used
            if len(splited) == 1:
                # get single-line attribute name
                return splited[0], identifier.SINGLE

            # when separator is used once
            elif len(splited) == 2:
                # when there is start statement
                if splited[0] == 'begin': 
                    # get multi-line attribute name
                    return splited[1], identifier.MULTI_BEGIN

                # when there is stop statement
                elif splited[0] == 'end':
                    # get multi-line attribute name
                    return splited[1], identifier.MULTI_END

                # when there is other statement
                else:
                    # attribute statement is not supported
                    raise ValueError('config: attribute category is not correct')

            # when separator is used many times
            else:
                # attribute separator ':' is not used correctly
                raise ValueError('config: attribute syntax is not correct')

        else:
            # attribute markers '<' and '>' are not used correctly
            raise ValueError('config: attribute syntax is not correct')

    except IndexError:
        # no printable characters in line
        raise AttributeError('config: line is empty')

#------------------------------------------------------------
def template_read(template_file_path):
    # read template file
    with open(template_file_path) as file:
        template_lines = file.readlines()

    template_attributes = {}

    name = ''
    state = read_state.SEARCH_FOR_ATTRIBUTE
    value = []

    for line in template_lines:
        # when in previous line found single-line attribute
        if state == read_state.GET_SINGLE_LINE_VALUE:
            # add attribute with single-line value
            template_attributes[name] = line
            # search for possible next attribute
            state = read_state.SEARCH_FOR_ATTRIBUTE

        # when searching for attribute or getting multi-line attribute
        else:
            try:
                # parse line for possible attribute definition
                id, id_type = config_line_attribute_get(line)

                if state == read_state.SEARCH_FOR_ATTRIBUTE:
                    # when single-line attribute is defined
                    if id_type == identifier.SINGLE:
                        name = id
                        state = read_state.GET_SINGLE_LINE_VALUE

                    # when multi-line start attribute is defined
                    elif id_type == identifier.MULTI_BEGIN:
                        name = id
                        value = []
                        state = read_state.GET_MULTI_LINE_VALUE

                    # when multi-line stop attribute is defined
                    else:
                        # multi-line start attribute is missing
                        raise ValueError('error: bad attribute')

                elif state == read_state.GET_MULTI_LINE_VALUE:
                    # when
                    if id_type == identifier.MULTI_END and name == id:
                        # add attribute with multi-line value
                        template_attributes[name] = value
                        # search for possible next attribute
                        state = read_state.SEARCH_FOR_ATTRIBUTE

                    # when
                    else:
                        # attributes configuration is not correct
                        raise ValueError('error: bad attribute')

                else:
                    raise ValueError('error: bad value')

            # when line does not define any attribute
            except ValueError:
                # when multi-line attribute is in progress
                if state == read_state.GET_MULTI_LINE_VALUE:
                    # add line to multi-line attribute
                    value.append(line)

                # when valid attribute definition is missing
                else:
                    # attributes configuration is not correct
                    raise ValueError('error: bad attribute')

            # when line is empty
            except AttributeError:
                # when multi-line attribute is in progress
                if state == read_state.GET_MULTI_LINE_VALUE:
                    # add line to multi-line attribute
                    value.append(line)

    # when there is some incomplete attribute
    if state != read_state.SEARCH_FOR_ATTRIBUTE:
        # attributes configuration is not correct
        raise ValueError('error: bad attribute')

    return template_attributes

#------------------------------------------------------------
def sources_names_get(directory_path):
    sources_names = []

    # get all files from directory
    files = os.listdir(directory_path)

    for file_name in files:
        # when file is a C language source
        if file_name.endswith('.c'):
            # get file base name
            file_name_base = os.path.splitext(file_name)[0]

            # add name to sources list
            sources_names.append(file_name_base)

    # when no files were found
    if not sources_names:
        # no sources found
        raise IndexError('sources not found')

    return sources_names

#------------------------------------------------------------
def objects_build_rules_create(sources_names):
    max_length = 0
    build_rules = []

    for source_name in sources_names:
        # generate object build rule
        build_rule = template_attributes['object-build'].format(source_name)
        splited = build_rule.split(':', 1)
        build_rules.append(splited)

        # when length is greater than all previous
        if len(splited[0]) > max_length:
            # set new maximum
            max_length = len(splited[0])

    make_objects_list = []

    # add break and comment
    make_objects_list.append('\n')
    make_objects_list.extend(template_attributes['object-comment'])

    for rule_splited in build_rules:
        # create whitespace complement to maximum length
        chars = ' ' * (max_length - len(rule_splited[0]))

        # add generated build rule of source file
        make_objects_list.append(rule_splited[0] + ':' + chars + rule_splited[1])

    return make_objects_list

#------------------------------------------------------------
def executable_link_rule_create(project_name, sources_names):
    make_executable_list = []

    # add break and comment
    make_executable_list.append('\n')
    make_executable_list.extend(template_attributes['executable-comment'])

    # generate executable link rule
    link_rule = template_attributes['executable-link'].format(project_name)

    # add line break symbol
    link_rule = link_rule.rstrip('\n') + ' $' + '\n'

    # add executable link rule
    make_executable_list.append(link_rule)

    for i, source_name in enumerate(sources_names):
        # generate link rule for object file
        link_rule = template_attributes['object-link'].format(source_name)

        # when there is not last object file
        if i < len(sources_names) - 1:
            # add line break symbol
            link_rule = link_rule.rstrip('\n') + ' $' + '\n'

        # add generated link rule of object file
        make_executable_list.append(link_rule)

    return make_executable_list

# define project
project_path = os.getcwd()
project_name = os.path.basename(project_path)

# define template file
template_file_name = 'build-gen.template'
template_file_path = os.path.join('/usr/local/etc/build-gen', template_file_name)

# define ninja build script file
ninja_build_file_name = 'build.ninja'
ninja_build_file_path = os.path.join(project_path, ninja_build_file_name)

try:
    # generate project source file list
    project_sources = sources_names_get(project_path)

    # get attributes from temaplate file
    template_attributes = template_read(template_file_path)

    print('Project Name: ' + project_name)
    print('Found C Source Files:')

    # show all found sources
    for file_name in project_sources:
        print(file_name + '.c')

    # create ninja build script
    build_ninja_text = []
    # generate first section
    build_ninja_text += template_attributes['rules-base']
    # generate build rules
    build_ninja_text += objects_build_rules_create(project_sources)
    # generate link rule
    build_ninja_text += executable_link_rule_create(project_name, project_sources)

    # save generated build script into file
    with open(ninja_build_file_path, "w") as file:
        file.writelines(build_ninja_text)

    print('Created Build Script: ' + '\'' + ninja_build_file_name + '\'')

# when file read or write has failed
except OSError as error:
    print('[ERROR] input output error')
    print(f"{error}")

# when no sources were found in working directory
except IndexError as error:
    print('[ERROR] no source files in this directory')
    print(f"{error}")

# when attributes configuration is not valid
except ValueError as error:
    print('[ERROR] attributes config not correct')
    print(f"{error}")

# when required attribute value is not configured
except KeyError as error:
    print('[ERROR] missing attribute in template file')
    print(f"{error}")
