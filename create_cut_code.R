# cut looming presentations
# LL Faber
library(readxl)
library(tidyverse)


#data on looms ####
loompres_fish <- read_excel("~/Library/CloudStorage/GoogleDrive-lefa1150@colorado.edu/Shared drives/Field Research Videos/Gil Lab/Projects_2024/iPad_looming_stimulus_2024/Coarse_Looming_Analysis.xlsx", 
                            sheet = "fish_present", col_types = c("date", 
                                                                  "text", "text", "text", "numeric", 
                                                                  "text", "text", "text", "text", "text", 
                                                                  "text", "text", "text", "text", "text", 
                                                                  "text", "text", "text", "text", "text", 
                                                                  "skip", "skip"))
setwd("/Users/Lena/Documents/CU_Boulder/PhD/gillab/Looming/Looming")
loompres_fish <- read.csv("Coarse_Looming_fish_present.csv")
loompres_fish <- loompres_fish[-779, ]

# make list of the files we want to cut ####
setwd("/Users/Lena/Library/CloudStorage/GoogleDrive-lefa1150@colorado.edu/Shared drives/Field Research Videos/Gil Lab/Curacao_2024/looming_stimulus")
target_videos_files <- paste0(unique(loompres_fish$video_file),".MP4") #unique to prevent repetition 

# Get all subdirectories that have "/A" at the end
a_folders <- list.dirs(path = ".", recursive = TRUE, full.names = TRUE)
a_folders <- a_folders[grepl("A$", a_folders)]  # Keep only "A" folders
a_folders <- a_folders[-c(8,9,12)] #romove habitat ones

# Find all files in "A" folders
all_files <- list.files(path = a_folders, recursive = TRUE, full.names = TRUE)

# Filter for target video files
matching_files <- all_files[basename(all_files) %in% target_videos_files]
matching_files_names <- gsub(".MP4$", "", basename(matching_files), ignore.case = TRUE)
loompres_fish$full_path <- matching_files[match(loompres_fish$video_file, matching_files_names)]
loompres_fish <- loompres_fish |> mutate(loom_ID = row_number())

#create a folder for cut loom videos
# Define target folder for copied videos
target_folder <- "looms_fish_present"

# Create folder if it doesn't exist
if (!dir.exists(target_folder)) {
  dir.create(target_folder)
}

#put these files in ffmpeg code to cut out the loom #####
full_code <- character(nrow(loompres_fish))

for (i in 1:nrow(loompres_fish)) {
  
  input <- loompres_fish$full_path[i]
  
  # Convert time string to minutes and seconds
  time_parts <- strsplit(loompres_fish$time[i], ":")[[1]]
  minutes <- as.numeric(time_parts[1])
  seconds <- as.numeric(time_parts[2])
  total_seconds <- minutes * 60 + seconds - 5  # Subtract 5 seconds
  
  # Ensure time does not go negative
  if (total_seconds < 0) {
    total_seconds <- 0
  }
  
  # Convert back to "MM:SS" format for ffmpeg
  new_minutes <- total_seconds %/% 60
  new_seconds <- total_seconds %% 60
  timestamp <- sprintf("00:%02d:%02d", new_minutes, new_seconds)
  
  duration <- "00:00:15"
  output <- paste0(loompres_fish$video_file[i],"loom_", loompres_fish$loom_ID[i], ".mp4")
  
  cut_code <- paste0("ffmpeg -i ", input, " -ss ", timestamp, " -t ", duration, " -c:v copy -c:a copy ", target_folder,"/" ,output)
  full_code[i] <- cut_code
}

writeLines(full_code, "ffmpeg_commands.txt")
writeLines(full_code, "/Users/Lena/Documents/CU_Boulder/PhD/gillab/Looming/Looming/ffmpeg_commands.txt")

# cd "/Users/Lena/Library/CloudStorage/GoogleDrive-lefa1150@colorado.edu/Shared drives/Field Research Videos/Gil Lab/Curacao_2024/looming_stimulus"

# code worked semi-ish, extract numbers 
setwd("~/Library/CloudStorage/GoogleDrive-lefa1150@colorado.edu/Shared drives/Field Research Videos/Gil Lab/Curacao_2024/looming_stimulus/looms_fish_present")
files <- list.files()
# Extract numbers before ".mp4"
numbers <- sub(".*loom_(\\d+)\\.mp4", "\\1", files)
pattern <- paste0("loom_", numbers, "\\.mp4", collapse = "|")

# Filter out lines that match any of the extracted numbers
filtered_code <- full_code[!grepl(pattern, full_code)]
setwd("~/Library/CloudStorage/GoogleDrive-lefa1150@colorado.edu/Shared drives/Field Research Videos/Gil Lab/Curacao_2024/looming_stimulus/")
writeLines(filtered_code, "ffmpeg_commands_filt.sh")
writeLines(filtered_code, "/Users/Lena/Documents/CU_Boulder/PhD/gillab/Looming/Looming/ffmpeg_commands_filt.txt")

#cut vids with response first 
cut <- loompres_fish[numbers,]
cut <- cut |> filter(response == "y")
resp <- loompres_fish |> filter(response == "y")
numbers_resp <- as.character(resp$loom_ID)
pattern2 <- paste0("loom_", numbers_resp, "\\.mp4", collapse = "|")
filtered_code_resp <- full_code[grepl(pattern2, full_code)]
writeLines(filtered_code_resp, "/Users/Lena/Documents/CU_Boulder/PhD/gillab/Looming/Looming/ffmpeg_commands_filt_resp.txt")
