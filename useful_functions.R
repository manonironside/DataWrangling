# Create sequential subject IDs from true IDs
## 1) Read in data frame
## 2) add variable 'num_id' to data frame
### Input:
  # df: should be a data frame including column labeled 'SubjectID' (or else, change name in function)
  # which includes the original raw subject IDs (e.g. '101', '103', '107')
sequential_ids <- function(df) {
  df <- df %>%
    #Sort data frame to your liking
    arrange(SubjectID, trial_index)
  #Add numerical ID 
  df <- df%>% mutate(
    num_id = as.numeric(factor(df$SubjectID, levels = unique(df$SubjectID)))
  )
  return(df) 
}

# Plot a histogram of student grades from multiple graders
# which includes a vertical line showing the average grade
### Input:
  # grades_df: should be a data frame containing the columns 'Grade' and 'Grader'
  # title: should be a string variables including a title for the graph (e.g. title <- 'Midterm 2 grade distribution by grader')

plot_multigrader_histogram <- function(grades_df, title) {
  grades_df$Grader <- as.factor(grades_df$Grader)
  grader_means <- grades_df %>% group_by(Grader) %>% summarise(
    average = mean(Grade),
    number_graded = n()
  )
  p <- ggplot(grades_df, aes(Grade, fill = Grader)) + 
    geom_histogram(bins = 12, alpha = 0.4, color = "black", aes(y = ..count..), position = 'identity') +
    scale_fill_viridis(discrete = T, begin = .5) +
    geom_vline(data = grader_means, aes(xintercept = average, col = Grader), linetype = "dashed") +
    ggtitle(title)
  return(p)
}

# Negate the %in% function to create a %notin% function
## note: %in% and %notin% are particularly useful for selecting data from a frame that includes NAs
## since booleans will not work with NAs.

`%notin%` <- Negate(`%in%`)
## EXAMPLE:
## If I want to remove participant ids '101' and '105' from my dataset:
## new_df <- old_df %>% filter(id %notin% c("101","105"))

# Derive d prime and criterion from signal detection data
## Note: this code was adapted from: https://lindeloev.net/calculating-d-in-python-and-php/
### Input:
## hits, misses, fas, crs: each a list of hits, misses, false alarms, and correct rejections
## id: a list of ids, corresponding with the order of hits, misses, false alarms, and correct rejection

SDT <- function(id, hits, misses, fas, crs) {
  half_hit <- 0.5/(hits + misses)
  half_fa <- 0.5/(fas + crs)
  
  hit_rate <- hits/(hits + misses)
  if(hit_rate ==1) {
    hit_rate <- 1-half_hit
  }
  if(hit_rate ==0) {
    hit_rate <- half_hit
  }
  
  fa_rate = fas/(fas+crs)
  if(fa_rate == 1) {
    fa_rate <- 1-half_fa
  }
  if(fa_rate ==0) {
    fa_rate <- half_fa
  }
  d <- qnorm(hit_rate) - qnorm(fa_rate)
  c <- -(qnorm(hit_rate) + qnorm(fa_rate)) /2
  out <- data.frame("id" = id, "d_prime" = d, "c" = c, "slips" = fas)
  return(out)
}
  