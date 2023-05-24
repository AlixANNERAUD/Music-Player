import Graphics
import This
import Drive
import Sound
import System
import Softwares

var Window = This.Get_Window()
var Software = This.Get_This()
var Title_Label = Graphics.Label_Type()
var Slider = Graphics.Slider_Type()

var First_Row = Graphics.Object_Type()
var Second_Row = Graphics.Object_Type()
var Third_Row = Graphics.Object_Type()
var Fourth_Row = Graphics.Object_Type()

var Next_Button = Graphics.Button_Type()
var Play_Pause_Button = Graphics.Button_Type()
var Play_Pause_Button_Label = Graphics.Label_Type()
var Previous_Button = Graphics.Button_Type()
var Random_Button = Graphics.Button_Type()
var Repeat_Button = Graphics.Button_Type()

var Current_Time_Label = Graphics.Label_Type()
var Total_Time_Label = Graphics.Label_Type()

var File_Is_Playing = false

var File_Player = Sound.File_Player_Type()

var WAV_Decoder = Sound.WAV_Decoder_Type()

var Continue = true

var Current_Time_Label_String = ""

var Next_Refresh = 0

var Music_File = Drive.File_Type()

def Set_Interface_Button(Parent, Button, Text)
    Button.Create(Parent)
    Button.Add_Event(Software, Graphics.Event_Code_Clicked)

    Label = Graphics.Label_Type()
    Label.Create(Button)
    Label.Set_Text(Text)
end

def Set_Interface_Row(Parent, Row)
    Row.Create(Parent)
    Row.Set_Height(Graphics.Size_Content)
    Row.Set_Width(Graphics.Get_Percentage(100))
    Row.Set_Flex_Flow(Graphics.Flex_Flow_Row)
    Row.Set_Flex_Alignment(Graphics.Flex_Alignment_Space_Evenly, Graphics.Flex_Alignment_Center, Graphics.Flex_Alignment_Center)
end

def Set_Interface()

    Window.Set_Title("Music Player")

    Window_Body = Window.Get_Body()
    Window_Body.Set_Flex_Flow(Graphics.Flex_Flow_Column)
    Window_Body.Set_Flex_Alignment(Graphics.Flex_Alignment_Space_Evenly, Graphics.Flex_Alignment_Center, Graphics.Flex_Alignment_Center)

    Set_Interface_Row(Window_Body, First_Row)

    Set_Interface_Button(First_Row, Previous_Button, "Open")

    Title_Label.Create(First_Row)
    Title_Label.Set_Text("Michel_Forever.mp3")
 
    Set_Interface_Row(Window_Body, Third_Row)
    
    Current_Time_Label.Create(Third_Row)
    Current_Time_Label.Set_Text("00:00")

    Slider.Create(Third_Row)
    Slider.Add_Event(Software, Graphics.Event_Code_Released)
    Slider.Set_Width(Graphics.Get_Percentage(60))

    Total_Time_Label.Create(Third_Row)
    Total_Time_Label.Set_Text("00:00")

    Set_Interface_Row(Window_Body, Fourth_Row)

    Set_Interface_Button(Fourth_Row, Random_Button, Graphics.Get_Symbol(Graphics.Symbol_Code_Shuffle))
    Set_Interface_Button(Fourth_Row, Previous_Button, Graphics.Get_Symbol(Graphics.Symbol_Code_Previous))
   
    Play_Pause_Button.Create(Fourth_Row)
    Play_Pause_Button.Add_Event(Software, Graphics.Event_Code_Clicked)
    Play_Pause_Button_Label.Create(Play_Pause_Button)
    Play_Pause_Button_Label.Set_Text(Graphics.Get_Symbol(Graphics.Symbol_Code_Play))

    Set_Interface_Button(Fourth_Row, Next_Button, Graphics.Get_Symbol(Graphics.Symbol_Code_Next))
    Set_Interface_Button(Fourth_Row, Repeat_Button, Graphics.Get_Symbol(Graphics.Symbol_Code_Loop))
end

def Execute_Instruction(Instruction) 
    if Instruction.Get_Sender() == Graphics.Get_Pointer()
        Current_Target = Instruction.Graphics_Get_Current_Target()
        if Instruction.Graphics_Get_Code() == Graphics.Event_Code_Clicked
            if Current_Target == Play_Pause_Button
                if File_Is_Playing
                    File_Is_Playing = false
                    Play_Pause_Button_Label.Set_Text(Graphics.Get_Symbol(Graphics.Symbol_Code_Pause))
                else
                    File_Is_Playing = true
                    Play_Pause_Button_Label.Set_Text(Graphics.Get_Symbol(Graphics.Symbol_Code_Play))
                end
            end
        elif Instruction.Graphics_Get_Code() == Graphics.Event_Code_Released
            if Current_Target == Slider
                File_Player.Set_Time(Slider.Get_Value())
            end
        end
    elif Instruction.Get_Sender() == Softwares.Get_Pointer()
        if Instruction.Softwares_Get_Code() == Softwares.Event_Code_Close
            File_Is_Playing = false
            Continue = false
        end
    end
end

def Open_File(Path)

    Music_File = Drive.Open(Path, false, false, false)

    Output_Stream = Sound.Get_Current_Output_Stream()

    File_Player.Set(Music_File, Output_Stream, WAV_Decoder)

    File_Player.Begin()

    File_Player.Loop()  # Feed the first buffer to get information about the file

    Next_Refresh = 0

    Total_Time = File_Player.Get_Total_Time()

    Minutes = Total_Time / 60
    Seconds = Total_Time % 60

    Total_Time_Label_String = ""
    if Minutes < 10
        Total_Time_Label_String = "0"
    end
    Total_Time_Label_String += str(Minutes) + ":"
    if Seconds < 10
        Total_Time_Label_String += "0"
    end
    Total_Time_Label_String += str(Seconds)

    Total_Time_Label.Set_Text(Total_Time_Label_String)

    Slider.Set_Range(0, Total_Time)

    File_Is_Playing = true

end

Set_Interface()

Open_File("/Sub.wav")

while Continue
    while File_Is_Playing && Continue
        if File_Player.Loop() == 0
            File_Is_Playing = false
            Play_Pause_Button_Label.Set_Text(Graphics.Get_Symbol(Graphics.Symbol_Code_Pause))
        end

        if (Next_Refresh < System.Get_Up_Time_Milliseconds())
            if (Slider.Is_Dragged() == false)
                Current_Time = File_Player.Get_Time()
   
                Slider.Set_Value(Current_Time, false)

                Current_Time_String = ""
                if Current_Time / 60 < 10
                    Current_Time_String = "0"
                end
                Current_Time_String += str(Current_Time / 60) + ":"
                if Current_Time % 60 < 10
                    Current_Time_String += "0"
                end
                Current_Time_String += str(Current_Time % 60)
                Current_Time_Label.Set_Text(Current_Time_String)
                Next_Refresh = System.Get_Up_Time_Milliseconds() + 500
            end
            Next_Refresh = System.Get_Up_Time_Milliseconds() + 50
        elif This.Instruction_Available() > 0
            Execute_Instruction(This.Get_Instruction())
        end

        This.Delay(1)   # Avoids using 100% of the CPU
    end

    if This.Instruction_Available() > 0
        Execute_Instruction(This.Get_Instruction())
    end    
   
    This.Delay(50)
end
