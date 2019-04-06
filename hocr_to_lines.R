### This is Niko Partanen's example R script that processes
### Tesseract hocr output

library(tidyverse)
library(xml2)
library(measurements)
library(magick)
library(fs)

if (dir_exists("data")){
  dir_delete("data")
}

# We are taking a random sample when test and train set are
# divided, so setting seed is necessary to ensure reproducibility

set.seed(20170818)

# This function reads Alto file and saves it as individual files.
# Directory is simply the folder name, in this case `test` or `train`. 

hocr2lines <- function(xml_file, target_directory){
  
  if (! dir_exists(target_directory)){
    dir_create(target_directory) 
  }
  
  xml_basename <- str_extract(xml_file, "[^/]+(?=.hocr)")
  
  xml <- read_xml(xml_file)
  
  image_tif <- xml_file %>% str_replace_all(".hocr$", ".tif") %>%
    image_read() %>%
    image_threshold(type = "white") %>%
    image_convert(colorspace = "Gray") # simple binarization
  
  # image_tif %>% image_crop("730x65+200+1390")
  
  # Alto files use tenth of millimeter as the measure unit,
  # so units need to be converted to pixels -- this seems to work
  
  # mm10inch <- function(number){
  #   measurements::conv_unit((number / 10), "mm", "inch") * 300
  # }
  
  # This function saves individual line
  
  save_line <- function(page_image, info){
    
    # Let's create the directories if they don't exist
    if (! dir_exists(str_glue("{target_directory}/{info$folder_group}"))){
      dir_create(str_glue("{target_directory}/{info$folder_group}"))
    }
    
    crop_string <- str_glue("{info$width}x{info$height}+{info$left}+{info$top}")
    cropped_line <- image_crop(page_image, crop_string)
    image_write(cropped_line, str_glue("{target_directory}/{info$folder_group}/{xml_basename}-{info$order_id}-{info$id}.tif", format = "png"))
    cropped_line %>%
      image_convert("png") %>%
      image_write(str_glue("{target_directory}/{info$folder_group}/{xml_basename}-{info$order_id}-{info$id}.png"))
    write_lines(info$content, str_glue("{target_directory}/{info$folder_group}/{xml_basename}-{info$order_id}-{info$id}.txt"))
  }
  
  # Rounding function
  
  round_any <- function(x, accuracy, f=round){
    rounded_number <- f(x / accuracy) * accuracy
    str_pad(string = rounded_number, width = 4, pad = "0")
  }
  
  # Saving the lines is done in the end of this function
  
  xml %>% xml_find_all("//d1:span[@class='ocr_line']") %>%
    map_df(~ tibble(id = .x %>% xml_attr("id"),
                    bbox = .x %>% xml_attr("title") %>%
                      str_extract("(?<=bbox )[\\d ]+"),
                    content = .x %>% 
                      xml_find_all("./d1:span[@class='ocrx_word']") %>% 
                      xml_text %>% 
                      paste0(collapse = " ")) %>%
             separate(bbox, into = c("v1", "v2", "v3", "v4"), convert = TRUE)) %>%
    mutate(content = str_squish(content)) %>%
    filter(! content == '') %>%
    mutate(height = v4 - v2) %>% 
    mutate(width = v3 - v1) %>%
    mutate(left = v1) %>%
    mutate(top = v2) %>%
    # filter(str_detect(content, "Бур у")) %>%
  
                    
    #                 hpos = .x %>% xml2::xml_attr("HPOS") %>% as.numeric(),
    #                 vpos = .x %>% xml_attr("VPOS") %>% as.numeric(),
    #                 width = .x %>% xml_attr("WIDTH") %>% as.numeric(),
    #                 height = .x %>% xml_attr("HEIGHT") %>% as.numeric(),
    #                 content = .x %>% xml_find_all("./d1:String") %>% xml_attr("CONTENT") %>%
    #                   paste0(collapse = " "),
    #                 box_id = .x %>% xml_attr("ID"),
    #                 height_page = .x %>%
    #                   xml_find_first("//d1:Page") %>%
    #                   xml_attr("HEIGHT") %>% as.numeric,
    #                 width_page = .x %>%
    #                   xml_find_first("//d1:Page") %>%
    #                   xml_attr("WIDTH") %>% as.numeric)
    # ) %>%
    # mutate_if(is.double, mm10inch) %>% # here we do mm10inch
    # filter(! content == '') %>%
    mutate(order_id = 1:n() %>% str_pad(width = 4, pad = "0")) %>%
    mutate(folder_group = 1:n() %>% 
             round_any(accuracy = 100)) %>%
    # mutate(xmax = hpos + width,
    #        xmin = hpos,
    #        ymax = vpos + height,
    #        ymin = vpos) %>% 
    # mutate_if(is.double, round, digits = 0) %>%
    split(.$order_id) %>%
    walk(~ {
      save_line(page_image = image_tif, info = .x)})
  
}

# Here we list the files

hocr_files <- dir("pages/", 
                pattern = "hocr$", 
                recursive = TRUE,
                full.names = TRUE)



# Here the test and train set are split, 15% goes to testing.
# OCR training usually splits another test set while training,
# but for further evaluation this is useful.

# Both file lists are processed into lines

hocr_files %>%
  walk(~ {hocr2lines(xml_file = .x, target_directory = "data")})

