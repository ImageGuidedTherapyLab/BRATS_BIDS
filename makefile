SHELL := /bin/bash
SEQUENCE = $(shell seq -f "%03g" 1 484)
UIDLIST = $(addprefix A,$(SEQUENCE))
setup: $(addsuffix /ses-BRATS/anat/setup,$(addprefix sub-A,$(SEQUENCE)))

mriqc:
	mkdir -p derivatives/mriqc
	docker run -it --rm -v $(PWD):/data:ro -v $(PWD)/derivatives/mriqc:/out --user $$(id -u):$$(id -g)  poldracklab/mriqc:latest /data /out participant --participant_label $(UIDLIST)  --no-sub

# bids format
# https://bids-specification.readthedocs.io/en/bep-009/04-modality-specific-files/01-magnetic-resonance-imaging-data.html
sub-A%/ses-BRATS/anat/setup:
	mkdir -p $(@D)
	mkdir -p derivatives/manual_masks/sub-A$*/anat/
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 0 -o $(@D)/sub-A$*_ses-BRATS_FLAIR.nii.gz
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 1 -o $(@D)/sub-A$*_ses-BRATS_T1w.nii.gz
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 2 -o $(@D)/sub-A$*_ses-BRATS_ce_T1w.nii.gz
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 3 -o $(@D)/sub-A$*_ses-BRATS_T2w.nii.gz
	c3d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/labelsTr/BRATS_$*.nii.gz -binarize -o derivatives/manual_masks/sub-A$*/anat/sub-$*_desc-tumor_mask.nii.gz
