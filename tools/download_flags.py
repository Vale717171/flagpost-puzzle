import urllib.request
import json

flags = [
  {"id": "ar", "countryName": "Argentina", "capital": "Buenos Aires", "continent": "South America", "assetPath": "assets/flags/images/ar.png", "shortFact": "Argentina is the birthplace of the tango."},
  {"id": "au", "countryName": "Australia", "capital": "Canberra", "continent": "Oceania", "assetPath": "assets/flags/images/au.png", "shortFact": "Australia has more kangaroos than people."},
  {"id": "be", "countryName": "Belgium", "capital": "Brussels", "continent": "Europe", "assetPath": "assets/flags/images/be.png", "shortFact": "Belgium is famous for its chocolate and waffles."},
  {"id": "cn", "countryName": "China", "capital": "Beijing", "continent": "Asia", "assetPath": "assets/flags/images/cn.png", "shortFact": "China is home to the Great Wall, which is over 13,000 miles long."},
  {"id": "co", "countryName": "Colombia", "capital": "Bogotá", "continent": "South America", "assetPath": "assets/flags/images/co.png", "shortFact": "Colombia is known for producing the world's finest emeralds."},
  {"id": "dk", "countryName": "Denmark", "capital": "Copenhagen", "continent": "Europe", "assetPath": "assets/flags/images/dk.png", "shortFact": "Denmark is the birthplace of Lego."},
  {"id": "eg", "countryName": "Egypt", "capital": "Cairo", "continent": "Africa", "assetPath": "assets/flags/images/eg.png", "shortFact": "Egypt is home to the Great Pyramid of Giza, the only surviving ancient wonder."},
  {"id": "fi", "countryName": "Finland", "capital": "Helsinki", "continent": "Europe", "assetPath": "assets/flags/images/fi.png", "shortFact": "Finland has been named the happiest country in the world multiple times."},
  {"id": "in", "countryName": "India", "capital": "New Delhi", "continent": "Asia", "assetPath": "assets/flags/images/in.png", "shortFact": "India is the birthplace of chess."},
  {"id": "id", "countryName": "Indonesia", "capital": "Jakarta", "continent": "Asia", "assetPath": "assets/flags/images/id.png", "shortFact": "Indonesia is the largest archipelago in the world."},
  {"id": "ie", "countryName": "Ireland", "capital": "Dublin", "continent": "Europe", "assetPath": "assets/flags/images/ie.png", "shortFact": "Ireland is widely known as the Emerald Isle because of its lush greenery."},
  {"id": "il", "countryName": "Israel", "capital": "Jerusalem", "continent": "Asia", "assetPath": "assets/flags/images/il.png", "shortFact": "Israel contains the lowest point on earth, the Dead Sea."},
  {"id": "jm", "countryName": "Jamaica", "capital": "Kingston", "continent": "North America", "assetPath": "assets/flags/images/jm.png", "shortFact": "Jamaica is the birthplace of reggae music."},
  {"id": "ke", "countryName": "Kenya", "capital": "Nairobi", "continent": "Africa", "assetPath": "assets/flags/images/ke.png", "shortFact": "Kenya is famous for the Great Wildebeest Migration."},
  {"id": "kr", "countryName": "South Korea", "capital": "Seoul", "continent": "Asia", "assetPath": "assets/flags/images/kr.png", "shortFact": "South Korea is a global leader in internet connectivity speed."},
  {"id": "mx", "countryName": "Mexico", "capital": "Mexico City", "continent": "North America", "assetPath": "assets/flags/images/mx.png", "shortFact": "Mexico City is built over the ruins of a great Aztec city."},
  {"id": "ma", "countryName": "Morocco", "capital": "Rabat", "continent": "Africa", "assetPath": "assets/flags/images/ma.png", "shortFact": "Morocco is home to the oldest continuously operating university in the world."},
  {"id": "nl", "countryName": "Netherlands", "capital": "Amsterdam", "continent": "Europe", "assetPath": "assets/flags/images/nl.png", "shortFact": "The Netherlands has more bicycles than people."},
  {"id": "nz", "countryName": "New Zealand", "capital": "Wellington", "continent": "Oceania", "assetPath": "assets/flags/images/nz.png", "shortFact": "New Zealand was the first country to give women the right to vote."},
  {"id": "ng", "countryName": "Nigeria", "capital": "Abuja", "continent": "Africa", "assetPath": "assets/flags/images/ng.png", "shortFact": "Nigeria is the most populous country in Africa."},
  {"id": "no", "countryName": "Norway", "capital": "Oslo", "continent": "Europe", "assetPath": "assets/flags/images/no.png", "shortFact": "Norway is famous for its stunning coastal fjords."},
  {"id": "pe", "countryName": "Peru", "capital": "Lima", "continent": "South America", "assetPath": "assets/flags/images/pe.png", "shortFact": "Peru is home to the ancient Incan city of Machu Picchu."},
  {"id": "ph", "countryName": "Philippines", "capital": "Manila", "continent": "Asia", "assetPath": "assets/flags/images/ph.png", "shortFact": "The Philippines was named after King Philip II of Spain."},
  {"id": "pt", "countryName": "Portugal", "capital": "Lisbon", "continent": "Europe", "assetPath": "assets/flags/images/pt.png", "shortFact": "Portugal is the oldest country in Europe with unchanged borders."},
  {"id": "ru", "countryName": "Russia", "capital": "Moscow", "continent": "Europe", "assetPath": "assets/flags/images/ru.png", "shortFact": "Russia is the largest country in the world by land area."},
  {"id": "za", "countryName": "South Africa", "capital": "Pretoria", "continent": "Africa", "assetPath": "assets/flags/images/za.png", "shortFact": "South Africa is the only country with three capital cities."},
  {"id": "se", "countryName": "Sweden", "capital": "Stockholm", "continent": "Europe", "assetPath": "assets/flags/images/se.png", "shortFact": "Sweden was the first country in the world to ban smacking children."},
  {"id": "ch", "countryName": "Switzerland", "capital": "Bern", "continent": "Europe", "assetPath": "assets/flags/images/ch.png", "shortFact": "Switzerland is famous for its watches, chocolate, and historical neutrality."},
  {"id": "th", "countryName": "Thailand", "capital": "Bangkok", "continent": "Asia", "assetPath": "assets/flags/images/th.png", "shortFact": "Thailand is the only Southeast Asian country never colonized by a European power."},
  {"id": "tr", "countryName": "Turkey", "capital": "Ankara", "continent": "Asia", "assetPath": "assets/flags/images/tr.png", "shortFact": "Turkey is a transcontinental country, straddling both Europe and Asia."}
]

for flag in flags:
    url = f"https://flagcdn.com/w320/{flag['id']}.png"
    dest = f"assets/flags/images/{flag['id']}.png"
    print(f"Downloading {flag['id']}...")
    try:
        urllib.request.urlretrieve(url, dest)
    except Exception as e:
        print(f"Error downloading {flag['id']}: {e}")

# Read existing JSON
with open('assets/flags/flags.json', 'r') as f:
    existing_flags = json.load(f)

# Append new flags
existing_flags.extend(flags)

# Write back to JSON
with open('assets/flags/flags.json', 'w') as f:
    json.dump(existing_flags, f, indent=2)

print("Done!")
