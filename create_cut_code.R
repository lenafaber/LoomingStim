# cut looming presentations
# LL Faber

#data
loompres_fish <- read.csv("Coarse_Looming_fish_present.csv")
loompres_fish <- loompres_fish[-779, ]

#initiate txt file/list? 
full_code <- character(nrow(loompres_fish))

for (i in 1:nrow(loompres_fish)) {
  input <- paste0(loompres_fish$video_file[i], ".mp4")
  timestamp <- paste0("00:", loompres_fish$time[i]) # minus 5 sec 
  duration <- "00:00:15"
  output <- paste0("loom_", loompres_fish$loom_no[i], ".mp4")
  
  cut_code <- paste("$ ffmpeg -i", input, " -ss ", timestamp, " -t ", duration, " -c:v copy -c:a copy ", output)
  full_code[i] <- cut_code
}

writeLines(full_code, "ffmpeg_commands.txt")


 # $ ffmpeg -i input.mp4 -ss 00:05:20 -t 00:00:15 -c:v copy -c:a copy output1.mp4