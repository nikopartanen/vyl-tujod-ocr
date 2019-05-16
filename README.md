<a rel="license" href="http://creativecommons.org/publicdomain/mark/1.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/p/mark/1.0/88x31.png" /></a></a>

<a href="https://zenodo.org/badge/latestdoi/179815335"><img src="https://zenodo.org/badge/179815335.svg" alt="DOI"></a>

## Выль туйӧд OCR Ground Truth

This data package contains materials for training or fine-tuning OCR models to work with fonts and languages used in Выль туйӧд newspaper from 1930s, accessible in the [Fenno-Ugrica collection](https://fennougrica.kansalliskirjasto.fi) of the National Library of Finland. 

One particular aspect of this data is that Zyrian Komi orthography was changed several times between Molodcov Komi, Komi Latin and Cyrillic Komi, in 1939 in the middle of the year. 

| Year        | Orthography           | Example |
|------------ |----------------------| ---------|
|1931         |  Molodcov   | ![](./samples/1931_01.jpg) |
|1932         |  Molodcov   | ![](./samples/1932_01_15.jpg)         |
|1933         |  Komi Latin   | ![](./samples/1933_12.jpg) |
|1936         |  Molodcov   | ![](./samples/1936_01_10.jpg)         |
|1938         |  Molodcov   | ![](./samples/1938_01_12.jpg)         |
|1939         |  Molodcov       |  ![](./samples/1939_04.png)        |
|1939         |  Komi Cyrillic       |  ![](./samples/1939_09.jpg)        |

The goal is to have materials that cover all writing systems in this period, so that OCR models could perform sufficiently well on both writing systems. This is also an experiment in OCR model fine tuning and larger adaptation|.
