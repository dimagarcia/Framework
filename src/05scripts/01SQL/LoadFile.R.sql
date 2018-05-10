# Load in the data
df <- read.delim2("https://s3.amazonaws.com/assets.datacamp.com/blog_assets/scores_timed4.txt", 
                  header = FALSE, 
                  sep = "\t", 
                  dec = ".", 
                  row.names = c("M", "N", "O"), 
                  col.names= c("X", "Y", "Z", "A","B"), 
                  colClasses = c(rep("integer", 2),
                                 "date", 
                                 "numeric",
                                 "character"),
                  fill = TRUE, 
                  strip.white = TRUE, 
                  na.strings = "EMPTY", 
                  skip = 2)

# Print the data
print(df)


df <- read.delim2("avg_E_coli_v4_Build_6_exps466probes7459.tab ",
                  header = FALSE,
                  sep = "\t",
                  dec = ".",
                  row.names = c("M", "N", "O"),
                  col.names= c("X", "Y", "Z", "A","B"),
                  colClasses = c(rep("integer", 2),
                                 "date",
                                 "numeric",
                                 "character"),
                  fill = TRUE,
                  strip.white = TRUE,
                  na.strings = "EMPTY",
                  skip = 2)
avg_E_coli_v4_Build_6_exps466probes7459.tab