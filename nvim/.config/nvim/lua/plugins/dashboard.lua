vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#FC5200" })
local strava = [[
                                           
                                         
                 /\                      
                /±±\                     
               /±±±±\                    
              /±±±±±±\                   
             /±±±±±±±±\                  
            /±±±±±±±±±±\                 
           /±±±±±±±±±±±±\                
          /±±±±±±/\±±±±±±\               
         /±±±±±±/  \±±±±±±\              
        /±±±±±±/    \±±±±±±\             
       /⊥⊥⊥⊥⊥⊥/  ∘∘∘∘\⊥⊥⊥⊥⊥⊥\∘∘∘∘∘       
                  ∘∘∘∘       ∘∘∘∘        
                   ∘∘∘∘     ∘∘∘∘         
                    ∘∘∘∘   ∘∘∘∘          
                     ∘∘∘∘ ∘∘∘∘           
                      ∘∘∘ ∘∘∘            
                       ∘∘∘∘∘             
                        ∘∘∘              
                         ∘               
                                         
]]

local metroid = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠾⠛⠋⠉⠉⠉⠉⠙⠛⠷⢦⣄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣠⣴⠟⢁⣠⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⣄⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣼⠟⠁⣰⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣧⡀⠀⠀⠀
⠀⠀⢀⡾⠁⢠⣾⡟⠁⠀⠀⠀⣠⣾⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠈⢷⡀⠀⠀
⠀⢀⣾⠁⣠⣿⠏⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠈⣷⡀⠀
⠀⢸⡇⠀⣿⠏⠀⠀⢀⣴⣷⡀⠻⣿⣿⣿⣿⠟⢀⣾⣦⡀⠀⠀⠀⠀⠀⢸⡇⠀
⠀⢸⡇⠀⠀⠀⠀⠀⢸⣿⣿⣿⣦⣤⠈⠁⣤⣴⣿⣿⣿⡇⠀⠀⠀⢰⠃⢸⡇⠀
⠀⠈⢿⡀⠀⠀⠀⠀⠀⠻⠿⡿⠿⠃⠀⠀⠘⠿⢿⠿⠟⠀⠀⠀⡰⠟⢀⡿⠁⠀
⠀⠀⠈⢿⣤⡀⠀⣀⣤⣤⣤⣀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣀⠀⢀⣤⡿⠁⠀⠀
⠀⠀⠀⠀⠉⠛⠛⠋⣡⣤⣌⠙⠻⠶⣦⣴⠶⠟⠋⣡⣤⣌⠙⠛⠛⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⢀⣴⣶⠄⠠⣶⣦⡀⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⡏⠈⢿⣿⠀⠀⣿⡿⠁⢹⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⠀⠀⠉⠀⠀⠉⠀⠀⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

]]

local headers = {
  strava = strava,
  metroid = metroid,
}

local logo = headers.metroid

logo = string.rep("\n", 8) .. logo .. "\n\n"
return {
  "nvimdev/dashboard-nvim",
  opts = {
    config = {
      header = vim.split(logo, "\n"),
    },
  },
}
