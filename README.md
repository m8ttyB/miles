# The Miles Project
This is simply a repo to hold code for projects my kid and I work on. It will
likely be very low volume since he's fairly young. However, we've begun to work
on a few mixed project - hardware and software - that are reasonably complex
that tend to see a fair amount of delicate tweaking.

## projects

### GCP Minecraft Bedrock Server
A dockerized Minecraft Bedrock server running on GCP. Cheap and easy to control.

### GCP Minecraft Java Server
A big thanks to [Tom Larkworthy](https://futurice.com/blog/friends-and-family-minecraft-server-terraform-recipe) for sharing his work with GCP and terraform file.

Our kid - as of this writing, 8-years-old - is heavily into Minecraft. He asked that I set up a server for
him and his friends. I looked at hosting options; there are many. I wanted to control cost as well as be a
bit lazy and deal with the administrative hassles of administering a full Linux system. Give me Docker or
give me death!

The Java edition of Minecraft was my first attempt at getting a working set up. I later realized I needed
the Bedrock version of the server for game consoles such as the Nintendo Switch or XBox to successfully 
log in.

This works! But I quickly iterated and was able to reuse this to work with Bedrock.

### Robot Plant

Adafruit has a wonderful CLUE recipe for building a flower watering bot. this
was a wonderful little weekend project that my 6 year old was able to do the
build on. I did the code tweaks as well as flashing the firmware onto the
[Clue nRF52840 Express](https://www.adafruit.com/product/4500).

Link to the [Chauncy the Flower Care Bot project](https://learn.adafruit.com/chauncey-flower-watering-bot-clue/overview).

## License

Mozilla Public License 2.0

Permissions of this weak copyleft license are conditioned on making available source code of licensed files and modifications of those files under the same license (or in certain cases, one of the GNU licenses). Copyright and license notices must be preserved. Contributors provide an express grant of patent rights. However, a larger work using the licensed work may be distributed under different terms and without source code for files added in the larger work.
