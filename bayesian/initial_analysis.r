
script_dir <- getwd()
concrete_file_path <- file.path(script_dir, "bayesian/concrete_data.csv")


concrete_data <- read.csv(concrete_file_path)

# list column names
print(colnames(concrete_data))

# change column names
colnames(concrete_data)[1] <- "cement"
colnames(concrete_data)[2] <- "slag"
colnames(concrete_data)[3] <- "ash"
colnames(concrete_data)[4] <- "water"
colnames(concrete_data)[5] <- "superplasticizer"
colnames(concrete_data)[6] <- "coarseagg"
colnames(concrete_data)[7] <- "fineagg"
colnames(concrete_data)[8] <- "age"
colnames(concrete_data)[9] <- "strength"

print(colnames(concrete_data))

# save as cleansed  file
write.csv(concrete_data, file = "bayesian/concrete_data_cleansed.csv", row.names = FALSE)


cor_matrix <- cor(concrete_data)
print(cor_matrix)

pairs(concrete_data)


library(car)

lm_model <- lm(concrete_data$strength ~ ., data = concrete_data)
vif_values <- vif(lm_model)
print(vif_values)
