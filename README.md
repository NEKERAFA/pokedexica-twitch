# ![Pokédexica](/extra/logo.png)

A Pokédex quiz game for
[Numerica Twich Jam](https://itch.io/jam/numerica-twitch-jam)

[![Download on Itch.io](https://img.shields.io/badge/Itch.io-Download%20now-FF2449?logo=itchdotio&logoColor=white)](https://nekerafa.itch.io/pokedexica-twitch)
[![Made in Godot 4.1.1](https://img.shields.io/badge/Godot-4.1.1-blue?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Under GPLv3.0 license](https://img.shields.io/github/license/NEKERAFA/pokedexica-twitch)](LICENSE)

# Table of contents
- [About](#about)
- [Build](#about)
- [Contributing](#contributing)
- [License](#license)

# About

### **🇪🇸 Español**

Si parece que tu chat sabe contar, prepárate para un nuevo nivel de dificultad:
¿sabe tu chat el nombre de todos los Pokémons?

## 🎮 Mecánicas principales

Pokédexica es un minijuego para tu canal de Twitch, basado en
[Numerica de RothioTome](https://rothiotome.itch.io/numerica). El objetivo es
claro: consigue que tus espectadores completen la Pokédex Nacional (puedes
encontrar más información en
[https://www.pokemon.com/pokedex](https://www.pokemon.com/pokedex)) siguiendo
las siguientes restricciones:

- Cada espectador puede escribir el nombre de un Pokémon.
- Si un espectador escribe el nombre de un Pokémon que no es el siguiente en la
  Pokédex, la Pokédex se reiniciará.
- Un espectador no puede escribir el nombre de dos Pokémons consecutivos.

### 📌 Mecánicas a implementar

- Elegir la pokedex a jugar.
- Bannea temporalmente a los espectadores que se equivoquen.
- Pokédex con los Pokémons obtenidos por los espectadores:
  - Seleccionar pokedex a ver
  - Espectador que lo descubrió primero.
  - Veces descubierto.
- Ranking con los espectadores que más completaron la Pokédex.
- Veces que se completó la Pokédex.
- Añadir vamohacalmarno como squirtle.

## 🖥️ Obtén el juego

Pokédexica está disponible gratuitamente en [itch.io](https://itch.io) en las
siguientes plataformas:

- GNU/Linux x86 64 bits
- Windows 64 bits

---

### **🇬🇧 English**

If your chat seems to be able to count, get ready for the next level of
difficulty: Does your chat know the names of all the Pokémon?

## 🎮 Mainly features

Pokédexica is a mini-game for your Twitch channel, based on
[Numerica by RothioTome](https://rothiotome.itch.io/numerica). The aim is pretty
clear: Get your viewers to complete the National Pokédex (you can find more
information in
[https://www.pokemon.com/pokedex](https://www.pokemon.com/pokedex)) following
the next restrictions:

- Any viewer can send the name of a Pokémon.
- If a viewer sends the name of a Pokémon that is not the next in the Pokédex,
  the Pokédex will be restarted.
- A viewer can't send two consecutive Pókemons.

### 📌 Next features

- Timeout to each viewer who are wrong.
- Pokédex list with the Pokémons obtained by your viewers:
  - Viewer who found the Pokémon first.
  - Number of times the Pokémon was found.
- Ranking of the viewers who contributed most to the Pokédex.
- Number of times the pokedex was completed.

## 🖥️ Get the game

Pokédexica is avaliable freely in
[itch.io](https://nekerafa.itch.io/pokedexica-twitch) to the following
platforms:

- [GNU/Linux x86 64 bits](https://github.com/NEKERAFA/pokedexica-twitch/releases/download/v1.1.0/pokedexica-twitch_1.1_linux_x86_64.zip)
- [Windows 64 bits](https://github.com/NEKERAFA/pokedexica-twitch/releases/download/v1.1.0/pokedexica-twitch_1.1_win-x64.zip)
- [macOS](https://github.com/NEKERAFA/pokedexica-twitch/releases/download/v1.1.0/pokedexica-twitch_1.1_macos_unsigned.zip) *Note: this version is not tested yet*

# Build

You must download [Godot Engine 4.1.1](https://github.com/godotengine/godot/releases/tag/4.1.1-stable) to be able to export the game to your platform.

First of all, dowload the game source code using zip download in GitHub or cloning this repository using `git` cli command:

```bash
git clone https://github.com/NEKERAFA/pokedexica-twitch.git
```

Then, you must add your Twitch App client ID and client secret in order to Pokédexica can connect to Twitch API. The client ID is setted in [autoloads/globals.gd](autoloads/globals.gd) (don't worry to expose that, client ID is public):

```gdscript
12   const TWITCH_CLIENT_ID: String = "<your Client ID>"
```

Instead, client secret is private and this cannot be distributed, so you need to create a new script in [autoloads](autoloads) folder with the name `secrets.gd` before open the proyect in Godot Engine. You must to put the next code:

```gdscript
 1   const TWITCH_CLIENT_SECRET = "<your Client secret>"
```

**work in progress*

# Contributing

**work in progress*

# License

> GNU General Public License Version 3, 29 June 2007
>
> Copyright (c) 2023 Rafael Alcalde Azpiazu (NEKERAFA)
>
> You may copy, distribute and modify the software as long as you track
> changes/dates in source files. Any modifications to or software including (via
> compiler) GPL-licensed code must also be made available under the GPL along
> with build & install instructions.
>
> See all legal notice in LICENSE file
