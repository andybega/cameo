#
#   Fix missing CAMEO event types
#
#   There are some small differences between the ICEWS eventtypes and Phil 
#   Schrodt's CAMEO codebook event types. This script resolves them to the 
#   superset, i.e. it has all. 
#

library(dplyr)
library(readr)
library(stringr)

raw <- read_csv("data/eventtypes-icews.csv")

raw <- raw |> 
  mutate(usage_notes = str_replace_all(usage_notes, "‚Äú|‚Äù", "\""),
         usage_notes = str_replace_all(usage_notes, "‚Äô|‚Äò", "'"),
         example = str_replace_all(example, "‚Äú|‚Äù", "\""),
         example = str_replace_all(example, "‚Äô|‚Äò", "'"))

raw |> mutate(root_code = substr(code, 1, 2)) |> filter(nchar(code)>2) |> count(root_code)

cameo_codebook_counts <- tribble(
  ~root_code, ~n,
  "01", 10,
  "02", 27,
  "03", 28,
  "04", 7,
  "05", 8,
  "06", 5,
  "07", 6,
  "08", 25,
  "09", 5,
  "10", 27,
  "11", 12,
  "12", 26,  # ICEWS has 1213, Reject judicial cooperation
  "13", 22,
  "14", 26,
  "15", 6,  # ICEWS is missing 155, Mobilize or increase cyber-forces
  "16", 13,
  "17", 13,  # ICEWS is missing 176, Attack cybernetically
  "18", 14,  # ICEWS is missing 1834, Carry out location bombing 
  "19", 9,  # ICEWS is missing 1951, Employ precision-guided aerial munitions; 1952, Employ remotely piloted aerial munitions 
  "20", 7
)


extra <- read_csv("data/eventtypes-cameo-extra.csv", col_types = "ccncc")

eventtypes <- bind_rows(raw, extra) |>
  select(-c(eventtype_ID, nsLeft, nsRight)) |>
  arrange(code)

write_csv(eventtypes, file = "data/eventtypes.csv")
