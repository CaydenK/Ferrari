#!/usr/bin/ruby
# -*- coding: UTF-8 -*-


require 'find'
# require 'pp'
require 'json'
require 'pathname'

#全局变量定义
# $source_dir = './'                      #遍历文件夹的根目录
$source_dir = ARGV[0]                   #遍历文件夹的根目录
if !$source_dir
    abort("参数中需要附带转换器脚本工作文件夹，JSMethod和参数都应在该目录下")
end

$protocol = "FRRJSExport"               #js方法定义协议
$base_class = "NSObject"                #js方法插件的类定义的基类
$method_flag = "FRRJSMethod"            #js方法定义标识
$export_js = "./ferrariExport.js"       #导出的js文件名
$params_count_regex = "*"

# @interface ... : NSObject <$protocol> 
# @interface ... (...) <$protocol> 
$protocol_regex = /@interface\s+(\w+)\s*:\s*NSObject\s*<#{$protocol}>|@interface\s+(\w+)\s*\(.*\)\s*<#{$protocol}>/
# + (... FRRJSMethod {
$method_regex = /(\+\s*\((\s|(?<!\<).)*?\s+#{$method_flag}\s+{)/ 
$params_property_regex = /@property(\s|.)*?\w*\s*\**\s*(\w+)\s*;/


def get_oc_source_path(directory)
    paths = Array.new
    Find.find(directory) do |path|
        #忽略main.m
        if path.match("/main.m")
            next
        end

        if path =~ /[\s\S]{1,}\.[m|mm]$/
            paths.push(path)
            # if path.match(".mm")
            #     paths.push(path[0..-4])
            # else
            #     paths.push(path[0..-3])
            # end
        end
    end
    return paths.uniq
end

#清除注释内容
def clear_content_note_info(contents)
    note_regex = /(?<!:)\/\/.*|\/\*(\s|.)*?\*\// # 匹配注释的正则表达式
    result = contents.gsub!(note_regex, "")
    return result
end

#获取文件内容
def get_file_content(path)
    #读取文本内容
    file = File.open(path,"rb")
    #读取并清除注释
    contents = clear_content_note_info(file.read)
    file.close
    return contents    
end

#校验协议
def check_protocol_content(contents) 
    if contents =~ $protocol_regex
        return true
    end
end

def get_class_implementation(class_name,m_content)
    reg = /@implementation\s+#{class_name}\s+(\s|.)*?@end/
    match_result = m_content.match(reg)
    class_m_content = match_result[0]
    if class_m_content
        return class_m_content
    end
    return nil
end

# 获取类内容，
def get_bridge_class_contents(paths)
    bridge_class_contents = {}
    paths.each{|path|
        puts 'scan file:' + path
        h_path = ''
        if path.match(".mm")
            h_path = path[0..-4] + '.h'
        else
            h_path = path[0..-3] + '.h'
        end

        if !File.exist?(h_path)
            next
        end
        h_contents = get_file_content(h_path)
        m_contents = get_file_content(path)

        h_check_result = check_protocol_content(h_contents)
        m_check_result = check_protocol_content(m_contents)

        if h_check_result || m_check_result
    
            oc_class_names1 = h_contents.scan($protocol_regex)
            oc_class_names2 = m_contents.scan($protocol_regex)
            # oc_class_names2:[['TestScript'],['TestScript2']]
            (oc_class_names1+oc_class_names2).each { |tempArray| 
                tempArray.each{|class_name|
                    if class_name
                        class_contents = bridge_class_contents[class_name]
                        if !class_contents
                            class_contents = []
                            bridge_class_contents[class_name] = class_contents
                        end
                        class_contents.push(get_class_implementation(class_name,m_contents))
                    end
                }
            }
        end
    }
    return bridge_class_contents
end

#从implementation中获取方法列表
def get_bridge_class_method_list(class_name,bridge_class_contents)
    # path_info = ClassPath.new(h_path,path)
    bridge_class_method_list = []
    reg = /@implementation\s+#{class_name}\s+(\s|.)*?@end/

    bridge_class_contents.each {|class_implementation|
        if class_implementation
            method_regex_results = class_implementation.scan($method_regex)
            method_regex_results.each{ |anchors|
                method_string = anchors[0]
                if method_string
                    # pp method_string
                    bridge_class_method_list.push(method_string)
                end
            }
            puts "\n"
        end
    }
    return bridge_class_method_list
end

#获取bridge类的方法列表
def get_class_method_hash(bridge_class_contents)
    class_method_hash = {}
    bridge_class_contents.each{|class_name,class_contents|
        method_list = get_bridge_class_method_list(class_name,class_contents)
        class_method_hash[class_name] = method_list
    }
    return class_method_hash
end

#获取方selector
def get_method_selector(method_string)

    method_flag_redundancy_regex = /\s+FRRJSMethod\s*{/
    method_params_redundancy_regex = /\s*(:\s*\(\s*\w+\s*\**\s*\)\s*\w+\s*)|(:\s*\(\s*void\s*\(\s*\^\s*\)\s*\(\s*\w+\s*\**\s*\w*\s*\)\s*\)\s*\w+\s*)/
    method_return_redundancy_regex = /\+(\s|.)*?\)/
    
    method_selector = method_string.gsub(method_flag_redundancy_regex,"")
    method_selector = method_selector.gsub(method_params_redundancy_regex,":")
    method_selector = method_selector.gsub(method_return_redundancy_regex,"")

    return method_selector
end
#获取方法名
def get_method_name(method_selector)
    return method_selector.scan(/^\w+/)[0]
end




#获取方法参数/返回值详情
=begin 返回结构demo
{"selector"=>"allTypeWithInput:abcabc:",
    "name"=>"allTypeWithInput",
    "return"=>"HSATestOutput",
    "params"=>
     [{"class"=>"HSATestInput", "name"=>"inputParam", "type"=>0},
      {"class"=>"HSATestOutput", "name"=>"completion", "type"=>1}]}
=end
def get_method_detail_info(method_string)
    method_detail = {}
    return_param_regex = /\+\s*\(\s*(\w+)\s*\**\s*\)/
    return_class = method_string.scan(return_param_regex)[0][0]

    method_selector = get_method_selector(method_string)
    method_name = get_method_name(method_selector)
    method_detail["selector"] = method_selector
    method_detail["name"] = method_name
    method_detail["return"] = return_class
    params_detail_list = []
    method_detail["params"] = params_detail_list


    #匹配出:(HSATestInput *)inputParam 或者匹配出:(void(^)(HSATestOutput *))completion 或者匹配出:(void(^)(HSATestOutput *output))completion
    params_info_regex = /(:\s*\(\s*\w+\s*\**\s*\)\s*\w+)|(:\s*\(\s*void\s*\(\s*\^\s*\)\s*\(\s*\w+\s*\**\s*\w*\s*\)\s*\)\s*\w+)/
    method_string.scan(params_info_regex).each{|anchors|

        #params_type 0 => 对象类型， 1 => block(函数)类型
        for params_type in 0..(anchors.length-1) do
            params_string = anchors[params_type]
            if params_string == nil
                next
            end

            params_class_regex = /\(\s*(\w*)\s*\**\s*\w*\s*\)/
            params_name_regex = /\)\s*(\w+)/

            params_class = params_string.scan(params_class_regex)[0][0]
            params_name = params_string.scan(params_name_regex)[0][0]

            params_detail = {}
            params_detail["class"] = params_class
            params_detail["name"] = params_name
            params_detail["type"] = params_type
            params_detail_list.push(params_detail)
        end
    }
    return method_detail
end

#获取类、函数、参数结构
=begin 返回结构demo
{"FRRTestObject"=>
  [{"selector"=>"allTypeWithInput:abcabc:",
    "name"=>"allTypeWithInput",
    "return"=>"HSATestOutput",
    "params"=>
     [{"class"=>"HSATestInput", "name"=>"inputParam", "type"=>0},
      {"class"=>"HSATestOutput", "name"=>"completion", "type"=>1}]}]}
=end
def get_class_method_params_infos(class_method_hash)
    class_method_params_infos = {}
    class_method_hash.each{|class_name,method_list|
        class_method_params_infos[class_name] = []
        method_list.each{|method_string|
            method_detail_info = get_method_detail_info(method_string)
            class_method_params_infos[class_name].push(method_detail_info)
        }
    }
    return class_method_params_infos
end

#获取函数出参入参返回值所有类
def get_params_class_list(class_method_params_infos)
    params_class_list = []
    class_method_params_infos.each{|class_name,method_detail_info_list|
        method_detail_info_list.each{|method_detail|
            params_class_list.push(method_detail["return"])
            method_detail["params"].each{|params_detail|
                params_class_list.push(params_detail["class"])
            }
        }
    }
    return params_class_list.uniq
end


#查找参数类的定义
def get_params_content_infos(paths,params_class_list)
    params_content_infos = {}

    paths.each{|path|
        
        h_path = ''
        if path.match(".mm")
            h_path = path[0..-4] + '.h'
        else
            h_path = path[0..-3] + '.h'
        end

        if !File.exist?(h_path)
            next
        end

        h_contents = get_file_content(h_path)
        m_contents = get_file_content(path)
        params_class_list.each{|params_class_name|
            # if params_class_name !~ /^#{$params_prefix}/
            #     next
            # end
            if params_class_name == 'void' 
                next
            end

            params_cls_regex = /(@interface\s+#{params_class_name}\s*(:\s*\w+|\(\s*\w*\s*\))(\s|.)*?@end)/
            h_res = h_contents.scan(params_cls_regex)
            m_res = m_contents.scan(params_cls_regex)
            

            if h_res.length | m_res.length
                params_class_contents = params_content_infos[params_class_name]
                if params_class_contents == nil
                    params_class_contents = []
                    params_content_infos[params_class_name] = params_class_contents
                end
                
                if h_res.length > 0
                    params_class_contents.push(h_res[0][0])
                end
                if m_res.length > 0
                    params_class_contents.push(m_res[0][0])
                end
                
            end

        }    
    }
    return params_content_infos
end

#获取参数该类型的属性
def get_params_class_propertys(params_content_infos)
    params_class_propertys = {}
    params_content_infos.each{|params_class_name,params_class_contents|
        # if params_class_name !~ /^#{$params_prefix}/
        #     params_class_propertys[params_class_name] = nil
        #     next
        # end

        propertys = {}
        params_class_propertys[params_class_name] = propertys
        params_class_contents.each{|params_class_content|
            params_class_content_res = params_class_content.scan($params_property_regex)
            params_class_content_res.each{|result|
                params_name = result[1]
                propertys[params_name] = true
            }
        }

    }
    return params_class_propertys
end

#获取canIUse方法所需数据
def get_can_i_use_js_data(class_method_params_infos,params_class_propertys)
    can_i_use_hash = {}

    class_method_params_infos.each{|class_name,method_detail_info|
        method_detail_info.each{|method_detail|
            can_i_use_item = can_i_use_hash[method_detail["name"]]
            
            #多个类中，定义了同一个方法，以扫描到的第一个方法为准
            if can_i_use_item
                next
            end

            can_i_use_item = {}
            can_i_use_item["return"] = params_class_propertys[method_detail["return"]]
            method_detail["params"].each{|params_detail|
                can_i_use_item[params_detail["name"]] = params_class_propertys[params_detail["class"]]
            }
            can_i_use_hash[method_detail["name"]] = can_i_use_item
        }
    }
    can_i_use_json = JSON.generate(can_i_use_hash)
    return can_i_use_json
end

#获取需要导出的js方法内容
def get_js_function_content(class_method_params_infos)
    js_function_list = ""
    class_method_params_infos.each{|class_name,method_detail_info_list|
        method_detail_info_list.each{|method_detail|
            js_function = <<-JS_FUNCTION
ferrari.#{method_detail["name"]} = function(#{
    method_detail["params"].map{|params|params["name"]}.join(',')
}) {
    className = "#{class_name}";
    selector = "#{method_detail["selector"]}";
    params = #{
        #此处需要手动拼接json
        json_item_list = []
        for params_detail in method_detail["params"] do
            params_type = params_detail["type"]
            json_item_list.push("{\"type\":#{params_type},\"class\":\"#{params_detail["class"]}\",\"content\":#{params_detail["name"]}}")
        end
        params_to_js = "[" + json_item_list.join(",") + "]"
        params_to_js
    };
    #{
        call_native = ""
        if method_detail["return"] == "void"
            call_native = "this.callNative(className,selector,params,'null');"
        else
            call_native = "return this.callNative(className,selector,params,'#{method_detail["return"]}');"    
        end
    }
}
JS_FUNCTION
            js_function_list = js_function_list + js_function + "\n\n"
        }
    }
    return js_function_list
end

#处理canIUse内容和js方法列表的拼接
def append_js_content(can_i_use_json,js_function_list)
    export_js_content = "ferrari.canIUseData = " + can_i_use_json + "\n\n" + js_function_list;
    return export_js_content
end

#导出js内容到文件
def export_js_to_file(content)
    export_path = Pathname.new(File.dirname(__FILE__)).realpath + $export_js
    # pp export_path
    aFile = File.new(export_path, "r+")
    if aFile
       aFile.syswrite(content)
    else
       puts "Unable to open file!"
    end
end


paths = get_oc_source_path($source_dir)
# puts "paths:\n"
# pp paths

bridge_class_contents = get_bridge_class_contents(paths)
# puts "bridge_class_contents:\n"
# pp bridge_class_contents

class_method_hash = get_class_method_hash(bridge_class_contents)
# puts "class_method_hash:\n"
# pp class_method_hash

class_method_params_infos = get_class_method_params_infos(class_method_hash)
# puts "class_method_params_infos:\n"
# pp class_method_params_infos

params_class_list = get_params_class_list(class_method_params_infos)
# puts "params_class_list:\n"
# pp params_class_list

params_content_infos = get_params_content_infos(paths,params_class_list)
# puts "params_content_infos:\n"
# pp params_content_infos

params_class_propertys = get_params_class_propertys(params_content_infos)
# puts "params_class_propertys:\n"
# pp params_class_propertys

get_can_i_use_js_data = get_can_i_use_js_data(class_method_params_infos,params_class_propertys)
# puts "get_can_i_use_js_data:\n"
# pp get_can_i_use_js_data

js_function_content = get_js_function_content(class_method_params_infos)
# puts "js_function_content:\n"
# puts js_function_content

export_js_content = append_js_content(get_can_i_use_js_data,js_function_content)
export_js_to_file(export_js_content)
