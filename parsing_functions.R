# Regex to locate links in text
find_link <- regex("
  \\[   # Grab opening square bracket
  .+?   # Find smallest internal text as possible
  \\]   # Closing square bracket
  \\(   # Opening parenthesis
  .+?   # Link text, again as small as possible
  \\)   # Closing parenthesis
  ",
                   comments = TRUE)

# Function that removes links from text and replaces them with superscripts that are 
# referenced in an end-of-document list. 
sanitize_links <- function(text){
  if(PDF_EXPORT){
    str_extract_all(text, find_link) %>% 
      pluck(1) %>% 
      walk(function(link_from_text){
        title <- link_from_text %>% str_extract('\\[.+\\]') %>% str_remove_all('\\[|\\]') 
        link <- link_from_text %>% str_extract('\\(.+\\)') %>% str_remove_all('\\(|\\)')
        
        # add link to links array
        links <<- c(links, link)
        
        # Build replacement text
        new_text <- glue('{title}<sup>{length(links)}</sup>')
        
        # Replace text
        text <<- text %>% str_replace(fixed(link_from_text), new_text)
      })
  }
  text
}

# Take entire positions dataframe and removes the links 
# in descending order so links for the same position are
# right next to eachother in number. 
strip_links_from_cols <- function(data, cols_to_strip){
  for(i in 1:nrow(data)){
    for(col in cols_to_strip){
      data[i, col] <- sanitize_links(data[i, col])
    }
  }
  data
}

# Take a position dataframe and the section id desired
# and prints the section to markdown. 
print_section <- function(position_data, section_id){
  position_data %>% 
    filter(section == section_id) %>% 
    arrange(desc(start)) %>% 
    # arrange(desc(end)) %>% 
    mutate(id = 1:n()) %>% 
    pivot_longer(
      starts_with('description'),
      names_to = 'description_num',
      values_to = 'description'
    ) %>% 
    filter(!is.na(description) | description_num == 'description_1') %>%
    group_by(id) %>% 
    mutate(
      descriptions = list(description),
      no_descriptions = is.na(first(description))
    ) %>% 
    ungroup() %>% 
    filter(description_num == 'description_1') %>% 
    mutate(
      timeline = ifelse(
        is.na(start) | start == end,
        end,
        glue('{end} - {start}')
      ),
      description_bullets = ifelse(
        no_descriptions,
        ' ',
        map_chr(descriptions, ~paste('-', ., collapse = '\n'))
      )
    ) %>% 
    strip_links_from_cols(c('title', 'description_bullets')) %>% 
    mutate_all(~ifelse(is.na(.), 'N/A', .)) %>% 
    glue_data(
      "### {title}",
      "\n\n",
      "{institution}",
      "\n\n",
      "{loc}",
      "\n\n",
      "{timeline}", 
      "\n\n",
      "{description_bullets}",
      "\n\n\n",
    )
}

# Construct a bar chart of skills
build_skill_bars <- function(skills, out_of = 5){
  bar_color <- "#592727"
  # bar_color <- "#260101"
  # bar_color <- "#8C3027"
  # bar_color <- "#969696"
  bar_background <- "#d9d9d9"
  skills %>% 
    mutate(width_percent = round(100*level/out_of)) %>% 
    glue_data(
      "<div class = 'skill-bar'",
      "style = \"background:linear-gradient(to right,",
      "{bar_color} {width_percent}%,",
      "{bar_background} {width_percent}% 100%)\" >",
      "{skill}",
      "</div>"
    )
}

# Prints out from text_blocks spreadsheet blocks of text for the intro and asides. 
print_text_block <- function(text_blocks, label){
  filter(text_blocks, loc == label)$text %>%
    sanitize_links() %>%
    cat()
}



# teste Publicacoes

print_section_publi <- function(publications_data, section_id){
  publications_data %>% 
    filter(section == section_id) %>%
    arrange(desc(year)) %>% 
    mutate(id = 1:n()) %>% 
    mutate(
      timeline = glue('{year}')) %>%  
    # strip_links_from_cols(c('title')) %>% 
    mutate_all(~ifelse(is.na(.), '', .)) %>% 
    # mutate_all(~ifelse(is.na(.), 'N/A', .)) %>% 
    glue_data(
      "### {title}",
      "\n\n",
      "{authors}",
      "\n\n",
      "N/A",
      "\n\n",
      "{timeline}",
      "\n\n",
      "*{journal}* {volume}",
      "\n\n\n",
      # "{description_bullets}",
      # "\n\n\n",
    )
}


# teste cursos

print_cursos <- function(courses_data){
  courses_data %>% 
    # filter(section == section_id) %>% 
    arrange(desc(year)) %>% 
    mutate(id = 1:n()) %>% 
    mutate(
      timeline = glue('{year}')) %>%  
    # strip_links_from_cols(c('title')) %>% 
    mutate_all(~ifelse(is.na(.), 'N/A', .)) %>% 
    glue_data(
      "### {title}",
      "\n\n",
      "{loc}. {hours}.",
      "\n\n",
      "{city}",
      "\n\n",
      "{timeline}",
      "\n\n\n",
      # "{description_bullets}",
      # "\n\n\n",
    )
}

# teste cursos

print_cursos <- function(courses_data){
  courses_data %>% 
    # filter(section == section_id) %>% 
    arrange(desc(year)) %>% 
    mutate(id = 1:n()) %>% 
    mutate(
      timeline = glue('{year}')) %>%  
    # strip_links_from_cols(c('title')) %>% 
    mutate_all(~ifelse(is.na(.), 'N/A', .)) %>% 
    glue_data(
      "### {title}",
      "\n\n",
      "{loc}. {hours}.",
      "\n\n",
      "{city}",
      "\n\n",
      "{timeline}",
      "\n\n\n",
      # "{description_bullets}",
      # "\n\n\n",
    )
}



# teste eventos

print_section_events <- function(events_data, section_id){
  events_data %>% 
    filter(section == section_id) %>% 
    arrange(desc(year)) %>% 
    mutate(id = 1:n()) %>% 
    mutate(
      timeline = glue('{year}')) %>%  
    # strip_links_from_cols(c('title')) %>% 
    mutate_all(~ifelse(is.na(.), 'N/A', .)) %>% 
    glue_data(
      "### {title}",
      "\n\n",
      "{authors}",
      "\n\n",
      "{loc}",
      "\n\n",
      "{timeline}",
      # "\n\n",
      # "*{journal}* {volume}",
      "\n\n\n",
      # "{description_bullets}",
      # "\n\n\n",
    )
}
