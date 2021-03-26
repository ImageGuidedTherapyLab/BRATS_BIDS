SHELL := /bin/bash
SEQUENCE = $(shell seq -f "%03g" 1 484)
UIDLIST = $(addprefix A,$(SEQUENCE))
FLAIRLIST = $(addprefix B,$(SEQUENCE))
setup: $(addsuffix /ses-BRATS/anat/setup,$(addprefix sub-A,$(SEQUENCE)))
setupflair: $(addsuffix /ses-BRATS/anat/setup,$(addprefix sub-B,$(SEQUENCE)))

mriqc: $(foreach uid,$(UIDLIST),derivatives/mriqc/sub-$(uid)/ses-BRATS/anat/run) 
mriqcfl: $(foreach uid,$(FLAIRLIST),derivatives/mriqc/sub-$(uid)/ses-BRATS/anat/run) 

#docker run --entrypoint=/bin/bash CHILD_IMAGE
#docker run -it --rm -v /rsrch1/ip/dtfuentes/github/BraTS_BIDS:/data:ro -v /rsrch1/ip/dtfuentes/github/BraTS_BIDS/derivatives/mriqc:/out --user $(id -u):$(id -g) --entrypoint=/bin/bash poldracklab/mriqc:latest 
derivatives/mriqc/sub-%/ses-BRATS/anat/dbg:
	mkdir -p $(@D)
	docker run -it --rm -v $(PWD):/data:ro -v $(PWD)/derivatives/mriqc:/out --user $$(id -u):$$(id -g)  poldracklab/mriqc:latest /data /out participant --participant_label $*  --no-sub --work-dir /out --verbose-reports --write-graph --nprocs 12 --ants-nthreads 12 
derivatives/mriqc/sub-%/ses-BRATS/anat/run:
	mkdir -p $(@D)
	docker run -it --rm -v $(PWD):/data:ro -v $(PWD)/derivatives/mriqc:/out --user $$(id -u):$$(id -g)  poldracklab/mriqc:latest /data /out participant --participant_label $*  --no-sub                                                 --nprocs 12 --ants-nthreads 12 

# bids format
# https://bids-specification.readthedocs.io/en/bep-009/04-modality-specific-files/01-magnetic-resonance-imaging-data.html
sub-B%/ses-BRATS/anat/setup:
	mkdir -p $(@D)
	mkdir -p derivatives/manual_masks/sub-B$*/anat/
	mkdir -p derivatives/mriqc/sub-B$*/ses-BRATS/anat/
	ln -snf  ../../../sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_FLAIR.nii.gz  $(@D)/sub-B$*_ses-BRATS_T2w.nii.gz
	ln -snf  ./sub-B$*_ses-BRATS_T2w.json derivatives/mriqc/sub-B$*/ses-BRATS/anat/sub-B$*_ses-BRATS_FLAIR.json
	ln -snf  ../../../../../derivatives/mriqc/sub-B$*/ses-BRATS/anat/sub-B$*_ses-BRATS_T2w.json derivatives/mriqc/sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_FLAIR.json
sub-A%/ses-BRATS/anat/setup:
	mkdir -p $(@D)
	mkdir -p derivatives/manual_masks/sub-A$*/anat/
	mkdir -p derivatives/mriqc/sub-A$*/ses-BRATS/anat/
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 0 -o $(@D)/sub-A$*_ses-BRATS_FLAIR.nii.gz
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 1 -o $(@D)/sub-A$*_ses-BRATS_T1w.nii.gz
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 2 -o $(@D)/sub-A$*_ses-BRATS_ce_T1w.nii.gz
	c4d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/imagesTr/BRATS_$*.nii.gz -slice w 3 -o $(@D)/sub-A$*_ses-BRATS_T2w.nii.gz
	c3d -verbose /rsrch1/ip/rmuthusivarajan/imaging/BraTS/Task01_BrainTumour/labelsTr/BRATS_$*.nii.gz -binarize -o derivatives/manual_masks/sub-A$*/anat/sub-$*_desc-tumor_mask.nii.gz
