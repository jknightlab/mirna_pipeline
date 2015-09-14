# Identifying differentially expressed microRNAs
# between healthy contronls and AS patienes
--------------------------------------
The goal of this project was, starting from the
sequencing files provided by the Sequencing Core of
WTCHG, generate a list of candidate microRNAs
differentially expressed in healthy controls versus
patients with ankylosing spondylitis for further
experimental validation. Sequencing project number
is **P150188**.


## Experimental Design

Two groups of cells -- Th17 and non-Th27 -- were
separately sequenced for healthy controls and AS
patients. This table provides the names of the samples
and the names of the corresponding sequencing files.
Note that one of the samples -- **AS3-Th17** was not
sequenced due to failed library prep (message from
the core: *One sample, AS3-TH17, failed the library
prep and could not be included.*)

The miRNA were run on a HiSeq2500 Rapid mode. With *Rapid
mode* the libraries are run on a single sequencing
flowcell that has two lanes, so two sequencing files
will be produced for one sample (message from the core:
*the data can be merged between the lanes*).

In this table `AS` stands for AS patients and `HC` stands
for healthy controls.

| Sample type | File names                         |
| ----------- | ---------------------------------- |
| HC1-nonTh17 | WTCHG_189135_274, WTCHG_189136_274 |
| HC2-nonTh17 | WTCHG_189135_276, WTCHG_189136_276 |
| HC3-nonTh17 | WTCHG_189135_278, WTCHG_189136_278 |
| HC4-nonTh17 | WTCHG_189135_280, WTCHG_189136_280 |
|             |                                    |
| HC1-Th17    | WTCHG_189135_275, WTCHG_189136_275 |
| HC2-Th17    | WTCHG_189135_277, WTCHG_189136_277 |
| HC3-Th17    | WTCHG_189135_279, WTCHG_189136_279 |
| HC4-Th17    | WTCHG_189135_281, WTCHG_189136_281 |
|             |                                    |
| AS1-nonTh17 | WTCHG_189135_282, WTCHG_189136_282 |
| AS2-nonTh17 | WTCHG_189135_284, WTCHG_189136_284 |
| AS3-nonTh17 | WTCHG_189135_286, WTCHG_189136_286 |
| AS4-nonTh17 | WTCHG_189135_288, WTCHG_189136_288 |
|             |                                    |
| AS1-Th17    | WTCHG_189135_283, WTCHG_189136_283 |
| AS2-Th17    | WTCHG_189135_285, WTCHG_189136_285 |
| AS4-Th17    | WTCHG_189135_289, WTCHG_189136_289 |


<FONT COLOR="######">text text text text text</FONT>

```html
   // code for coloring
   <FONT COLOR="######">text text text text text</FONT>
```

Bioinformatic pipeline to analyze micro RNA sequencing data


#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
