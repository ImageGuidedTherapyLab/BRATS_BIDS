SHELL := /bin/bash
SEQUENCE = $(shell seq -f "%03g" 1 484)
UIDLIST = $(addprefix A,$(SEQUENCE))
FLAIRLIST = $(addprefix B,$(SEQUENCE))
setup: $(addsuffix /ses-BRATS/anat/setup,$(addprefix sub-A,$(SEQUENCE)))
setupflair: $(addsuffix /ses-BRATS/anat/setup,$(addprefix sub-B,$(SEQUENCE)))

mriqc: $(foreach uid,$(UIDLIST),derivatives/mriqc/sub-$(uid)/ses-BRATS/anat/run) 
mriqcfl: $(foreach uid,$(FLAIRLIST),derivatives/mriqc/sub-$(uid)/ses-BRATS/anat/run) 
gmm: $(foreach uid,$(UIDLIST),derivatives/gmm/sub-$(uid)/anat/healthygmm.nii.gz)
# keep tmp files
.SECONDARY: 

#docker run --entrypoint=/bin/bash CHILD_IMAGE
#docker run -it --rm -v /rsrch1/ip/dtfuentes/github/BraTS_BIDS:/data:ro -v /rsrch1/ip/dtfuentes/github/BraTS_BIDS/derivatives/mriqc:/out --user $(id -u):$(id -g) --entrypoint=/bin/bash poldracklab/mriqc:latest 
derivatives/mriqc/sub-%/ses-BRATS/anat/dbg:
	mkdir -p $(@D)
	docker run -it --rm -v $(PWD):/data:ro -v $(PWD)/derivatives/mriqc:/out --user $$(id -u):$$(id -g)  poldracklab/mriqc:latest /data /out participant --participant_label $*  --no-sub --work-dir /out --verbose-reports --write-graph --nprocs 12 --ants-nthreads 12 
viewdbg:
	vglrun itksnap -g derivatives/mriqc/mriqc_wf/anatMRIQC/AFNISkullStripWorkflow/_in_file_..data..sub-B001..ses-BRATS..anat..sub-B001_ses-BRATS_T2w.nii.gz/sstrip_orig_vol/sub-B001_ses-BRATS_T2w_conformed_calc.nii.gz -o derivatives/mriqc/mriqc_wf/anatMRIQC/AFNISkullStripWorkflow/_in_file_..data..sub-B001..ses-BRATS..anat..sub-B001_ses-BRATS_T2w.nii.gz/inu_n4/sub-B001_ses-BRATS_T2w_conformed_bias.nii.gz derivatives/mriqc/mriqc_wf/anatMRIQC/AFNISkullStripWorkflow/_in_file_..data..sub-B001..ses-BRATS..anat..sub-B001_ses-BRATS_T2w.nii.gz/inu_n4/sub-B001_ses-BRATS_T2w_conformed_corrected.nii.gz derivatives/mriqc/mriqc_wf/anatMRIQC/AFNISkullStripWorkflow/_in_file_..data..sub-B001..ses-BRATS..anat..sub-B001_ses-BRATS_T2w.nii.gz/binarize/sub-B001_ses-BRATS_T2w_conformed_calc_mask.nii.gz derivatives/mriqc/mriqc_wf/anatMRIQC/AFNISkullStripWorkflow/_in_file_..data..sub-B001..ses-BRATS..anat..sub-B001_ses-BRATS_T2w.nii.gz/skullstrip/sub-B001_ses-BRATS_T2w_conformed_corrected_skullstrip.nii.gz -s derivatives/mriqc/mriqc_wf/anatMRIQC/_in_file_..data..sub-B001..ses-BRATS..anat..sub-B001_ses-BRATS_T2w.nii.gz/segmentation/segment_seg.nii.gz 
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
sub-A%/ses-BRATS/anat/viewmask:
	vglrun itksnap -g $(@D)/sub-A$*_ses-BRATS_ce_T1w.nii.gz  -s derivatives/manual_masks/sub-A$*/anat/sub-$*_desc-tumor_mask.nii.gz -o $(@D)/sub-A$*_ses-BRATS_FLAIR.nii.gz  $(@D)/sub-A$*_ses-BRATS_T1w.nii.gz  $(@D)/sub-A$*_ses-BRATS_T2w.nii.gz

derivatives/masks/sub-A%/anat/healthymask.nii.gz: 
	mkdir -p $(@D)
	c3d -verbose sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T2w.nii.gz -thresh 100 inf 1 0 -o $(@D)/brainmask.nii.gz derivatives/manual_masks/sub-A$*/anat/sub-$*_desc-tumor_mask.nii.gz -replace 1 0 0 1 -multiply -o $@
	echo vglrun itksnap -g sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_ce_T1w.nii.gz  -s $@ -o sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_FLAIR.nii.gz  sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T1w.nii.gz  sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T2w.nii.gz
derivatives/gmm/sub-A%/anat/healthygmm.nii.gz: derivatives/masks/sub-A%/anat/healthymask.nii.gz
	mkdir -p $(@D)
	/opt/apps/ANTS/dev/install/bin/Atropos -d 3  -c [3,0.0] -m [0.1,1x1x1] -i kmeans[3] -x $< -a sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T2w.nii.gz -a sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T1w.nii.gz  -o [$@,$(@D)/gmmPOSTERIORS%d.nii.gz] 
	echo vglrun itksnap -g sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_ce_T1w.nii.gz  -s $@ -o sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_FLAIR.nii.gz  sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T1w.nii.gz  sub-A$*/ses-BRATS/anat/sub-A$*_ses-BRATS_T2w.nii.gz
