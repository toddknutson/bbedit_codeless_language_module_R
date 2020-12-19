#!/usr/bin/env Rscript




#######################################################################
# Script parameters
#######################################################################


# Clear out any objects from workspace
rm(list = ls(all.names = TRUE))



#######################################################################
# Find installed packages
#######################################################################


message("Starting to build your BBEdit codeless language module")

# ---------------------------------------------------------------------
# part2 - Keywords
# ---------------------------------------------------------------------
message("Getting keywords")

keywords_logical <- c("TRUE", "FALSE", "T", "F")
keywords_logic <- c("!", "&amp;", "&amp;&amp;", "|", "||")
keywords_syntax <- c(":", "::", ":::", "$", "@", "{", "}", "[", "]", "[[", "]]", "%any%", "?", "+", "–", "*", "/", "^", "%%", "%/%", "&lt;", "&gt;", "&lt;=", "&gt;=", "==", "!=", "&lt;-", "&lt;&lt;-", "=", "-&gt;", "-&gt;&gt;")
keywords_reserved <- c("if", "else", "repeat", "while", "function", "for", "in", "next", "break", "NULL", "Inf", "-Inf", "NaN", "NA", "NA_integer_", "NA_real_", "NA_complex_", "NA_character_", "...")
keywords_my_favorites <- c("~", "%in%", "%&gt;%", "%$%", "%&lt;&gt;%", "%T%gt;%")

keywords <- c(keywords_logical, keywords_logic, keywords_syntax, keywords_reserved, keywords_my_favorites)

keywords_logical_comment <- '        <!-- R language logical operators. See ?logical in R for details -->'
keywords_logic_comment <- '        <!-- R language logic evaluators. See ?Logic in R for details -->'
keywords_syntax_comment <- '        <!-- R language syntax. See ?Syntax in R for details -->'
keywords_reserved_comment <- '        <!-- R language reserved words. See ?Reserved.in R for details -->'
keywords_my_favorites_comment <- '        <!-- My favorite syntax symbols (many from the magrittr R package) -->'



# ---------------------------------------------------------------------
# part4 - Get all predefined names
# ---------------------------------------------------------------------

message("Getting predefined names (i.e. function names from all your packages)")

# These are some names that are function names found below, but I dont want to include them.
custom_remove_list <- c("line", "x", "y")

my_packages <- unname(installed.packages()[, 1])


get_package_functions <- function(package_name) {
	curr_functions1 <- getNamespaceExports(package_name)
	# Clean up names
	if (length(curr_functions1) > 0) {
		curr_functions2 <- curr_functions1[!grepl("&", curr_functions1, fixed = TRUE)]
		curr_functions3 <- gsub("<", "&lt;", curr_functions2, fixed = TRUE)
		curr_functions4 <- gsub(">", "&gt;", curr_functions3, fixed = TRUE)
		curr_functions5 <- curr_functions4[!grepl("^[$0-9.%=:(@ ']", curr_functions4, fixed = FALSE)]
		curr_functions6 <- curr_functions5[!grepl("[ '&]", curr_functions5, fixed = FALSE)]
		# Remove any predefined names that also match keywords
		curr_functions7 <- curr_functions6[!curr_functions6 %in% keywords]
		curr_functions8 <- curr_functions7[!curr_functions7 %in% custom_remove_list]
		
		# Prepend package name
		curr_package_functions <- paste0(package_name, "::", curr_functions8)
		interleaved <- c(rbind(curr_functions8, curr_package_functions))
		return(interleaved)
	} else {
		interleaved <- NULL
		return(interleaved)
	}
}


names_list <- suppressWarnings(lapply(my_packages, FUN = get_package_functions))
# Get rid of NULLs
names_list2 <- Filter(Negate(function(x) is.null(unlist(x))), names_list)

names_vect <- unlist(names_list2)





# ---------------------------------------------------------------------
# build
# ---------------------------------------------------------------------

message("Creating output directory")

# Copy template files to current build dir
curr_build_name <- system('echo build_$(date +"%Y-%m-%d-%k%M%S" | sed "s/ //g")', intern = TRUE)
if (!dir.exists(curr_build_name)) {dir.create(curr_build_name, recursive = TRUE)}
# Wrap in invisible to prevent printing TRUE on the command line
invisible(file.copy(list.files("template", "*", full.names = TRUE), curr_build_name))



message("Writing new files")

# Open a new file for the keywords
con2 <- file(paste0(curr_build_name, "/R.plist.part2"), "w")

writeLines(keywords_logical_comment, con = con2)
for (m in seq_along(keywords_logical)) {
    line <- paste0("        <string>", keywords_logical[m], "</string>")
	writeLines(line, con = con2)
}


writeLines(keywords_logic_comment, con = con2)
for (m in seq_along(keywords_logic)) {
    line <- paste0("        <string>", keywords_logic[m], "</string>")
	writeLines(line, con = con2)
}


writeLines(keywords_syntax_comment, con = con2)
for (m in seq_along(keywords_syntax)) {
    line <- paste0("        <string>", keywords_syntax[m], "</string>")
	writeLines(line, con = con2)
}


writeLines(keywords_reserved_comment, con = con2)
for (m in seq_along(keywords_reserved)) {
    line <- paste0("        <string>", keywords_reserved[m], "</string>")
	writeLines(line, con = con2)
}




writeLines(keywords_my_favorites_comment, con = con2)
for (m in seq_along(keywords_my_favorites)) {
    line <- paste0("        <string>", keywords_my_favorites[m], "</string>")
	writeLines(line, con = con2)
}


close(con2)



# ---------------------------------------------------------------------
# Predefined names list
# ---------------------------------------------------------------------

# Open a new file for the names
con4 <- file(paste0(curr_build_name, "/R.plist.part4"), "w")

for (m in seq_along(names_vect)) {
    line <- paste0("        <string>", names_vect[m], "</string>")
	writeLines(line, con = con4)
}
close(con4)





# ---------------------------------------------------------------------
# Combine all files
# ---------------------------------------------------------------------



system(paste0("cat ", curr_build_name, "/R.plist.part* > ", curr_build_name, "/R.plist"))

# Save a package list 
write.table(data.frame(my_packages), paste0(curr_build_name, "/my_packages.txt"), quote = FALSE, sep = "\t", row.names = FALSE)


writeLines(capture.output(sessionInfo()), paste0(curr_build_name, "/session_info_", gsub(" |:", "_", Sys.time()), ".txt"))



message("Removing temp files")

# Delete intermediate files
if (file.exists(paste0(curr_build_name, "/R.plist.part1"))) {invisible(file.remove(paste0(curr_build_name, "/R.plist.part1")))}
if (file.exists(paste0(curr_build_name, "/R.plist.part2"))) {invisible(file.remove(paste0(curr_build_name, "/R.plist.part2")))}
if (file.exists(paste0(curr_build_name, "/R.plist.part3"))) {invisible(file.remove(paste0(curr_build_name, "/R.plist.part3")))}
if (file.exists(paste0(curr_build_name, "/R.plist.part4"))) {invisible(file.remove(paste0(curr_build_name, "/R.plist.part4")))}
if (file.exists(paste0(curr_build_name, "/R.plist.part5"))) {invisible(file.remove(paste0(curr_build_name, "/R.plist.part5")))}



# ---------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------


message(paste0("Your newly built codeless languaage module file (R.plist) can be found here: ", curr_build_name))






	
	
	
	

