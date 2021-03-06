tool
extends VisualScriptCustomNode

export var allow_back=true

func _get_caption():
	return "Say"
func _get_input_value_port_count():
	return 2
func _get_input_value_port_name( idx ):
	if idx==0:
		return "char id"
	elif idx==1:
		return "Dialog"
func _get_input_value_port_type( idx ):
	if idx==0 or idx==1:
		return TYPE_STRING


func _get_output_sequence_port_count():
	return 1
func _get_output_sequence_port_text(  idx ):
	return ""
func _get_output_value_port_count():
	return 0
func _get_output_value_port_name(  idx ):
	return ""
func _get_output_value_port_type(  idx ) :
	return 0
func _get_text():
	return ""
func _get_working_memory_size():
	return 1
func _has_input_sequence_port():
	return true

func _step(  inputs,  outputs,  start_mode, working_mem ):
		#ADD IN LIST
	
	var ren = Engine.get_main_loop().root.get_node("Window")
	var obj=ren.values
	if obj.has("RenVS"):
		if not(self in obj["RenVS"]["value"]):
			obj["RenVS"]["value"].append(self)
		else:
			print("is in list")
			allow_back=false
	else:
		var arr=Array()
		arr.append(self)
		ren.define("RenVS",[self])
		
	if self.get_instance_id() in ren.vnl:
		print(inputs[1],"already there")
		allow_back=false
	else:
		print(inputs[1],"added")
		ren.vnl.append(self.get_instance_id())
		
	#LOADING
	if ren.vis_loading:
		ren.say({"how":inputs[0],"what":inputs[1]})
		if ren.history_vis.size()>ren.load_counter:
			if ren.history_vis[ren.load_counter]==-1:
				ren.load_counter+=1
				return 0 | STEP_GO_BACK_BIT
			else:
				ren.load_counter+=1
				if not(get_instance_id() in ren.vnl):
					return ren.history_vis[ren.load_counter-1] | STEP_PUSH_STACK_BIT
				else:
					return ren.history_vis[ren.load_counter-1]
		
	var s={"how":inputs[0],"what":inputs[1]}
	var kwargs=[]
	#var ren = Engine.get_main_loop().root.get_node("Window")
	if !ren.has_meta("usingvis"):
		ren.set_meta("usingvis",true)
	if start_mode==START_MODE_CONTINUE_SEQUENCE:
		print("pushed back")
	if start_mode==START_MODE_BEGIN_SEQUENCE or start_mode==START_MODE_CONTINUE_SEQUENCE:
		ren.say(s)
		if !ren.get_meta("playing"):
			ren.start()
		else:
			ren.statements[ren.current_statement_id].enter()
		var n= VisualScriptFunctionState.new()
		#n.connect_to_signal(Engine.get_main_loop(),"idle_frame",[])
		n.connect_to_signal(ren,"exit_statement",kwargs)
		working_mem[0]=n
		print(n)
		return 0 | STEP_YIELD_BIT
	elif start_mode==START_MODE_RESUME_YIELD:
		#print("got choice ",ren.get_meta("last_choice"))
		print("push or next")
		if ren.get_meta("quitcurrent")==true:
			return 0 | STEP_NO_ADVANCE_BIT
		if ren.get_meta("go_back")==true:
			print("push")
			ren.history_vis.append(-1)
			return 0 | STEP_GO_BACK_BIT
		else:
			print("next")
			if allow_back:
				ren.history_vis.append(0)
				return 0 | STEP_PUSH_STACK_BIT
			else:
				ren.history_vis.append(0)
				return 0
		