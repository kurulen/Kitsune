IPC = {
   ["LastSeek"] = 0,
   ["InFD"] = RageFileUtil:CreateRageFile(),
   ["OutFD"] = RageFileUtil:CreateRageFile(),
}

IPC["Send"] = function(cmd, params)
   local prm
   if not params then prm = "" end

   SCREENMAN:SystemMessage("Command: "..cmd.." | Params: "..prm)
end
IPC["Recv"] = function()
   
end

IPCOpenEditor = function(file)
   IPC.Send("OpenEditor", file)
end
