with
    array_items as (
        select s.purified_plasma_id, ai.*
        from {{ ref("array_items") }} as ai
        inner join {{ ref("samples") }} as s using (sample_id)
    )

select
    purified_plasma_id,
    max(
        iff(reagent_type_id = 'TE Buffer (1X)', manufacturer_lot, null)
    ) as te_buffer_lot_number,
    max(
        iff(reagent_type_id = 'Molecular Grade H2O', manufacturer_lot, null)
    ) as molecular_grade_h2o_lot_number,
    max(
        iff(reagent_type_id = 'Ethanol (100%)', manufacturer_lot, null)
    ) as ethanol_lot_number,
    max(
        iff(reagent_type_id = 'AMPure XP Beads', manufacturer_lot, null)
    ) as ampure_xp_beads_lot_number,
    max(
        iff(
            reagent_type_id = 'Quant-iT PicoGreen dsDNA Reagent', manufacturer_lot, null
        )
    ) as quant_it_picogreen_dsdna_reagent_lot_number,
    max(
        iff(reagent_type_id = 'EB Buffer', manufacturer_lot, null)
    ) as eb_buffer_lot_number,
    max(
        iff(reagent_type_id = 'PhiX Control', manufacturer_lot, null)
    ) as phix_control_lot_number,
    max(
        iff(reagent_type_id = 'NovaSeq 6000 Buffer Cartridge', manufacturer_lot, null)
    ) as novaseq_6000_buffer_cartridge_lot_number,
    max(
        iff(
            reagent_type_id = 'NovaSeq 6000 SBS Cartridge (200 cycles)',
            manufacturer_lot,
            null
        )
    ) as novaseq_6000_sbs_cartridge_lot_number,
    max(
        iff(reagent_type_id = '1M Tris HCL pH 8.0', manufacturer_lot, null)
    ) as tris_hcl_ph_80_lot_number,
    max(
        iff(reagent_type_id = 'Qubit 1X dsDNA HS Assay Kit', manufacturer_lot, null)
    ) as qubit_1x_dsdna_hs_assay_kit_lot_number,
    max(
        iff(reagent_type_id = 'Indexing primer plate', manufacturer_lot, null)
    ) as indexing_primer_plate_lot_number,
    max(
        iff(reagent_type_id = 'Lambda DNA Standard', manufacturer_lot, null)
    ) as lambda_dna_standard_lot_number,
    max(
        iff(reagent_type_id = '1 N NaOH', manufacturer_lot, null)
    ) as naoh_1n_lot_number,
    max(
        iff(reagent_type_id = 'NovaSeq 6000 S2 Flow Cell', manufacturer_lot, null)
    ) as novaseq_6000_s2_flow_cell_lot_number,
    max(
        iff(
            reagent_type_id = 'NovaSeq 6000 S2 Cluster Cartridge',
            manufacturer_lot,
            null
        )
    ) as novaseq_6000_s2_cluster_cartridge_lot_number,
    max(
        iff(reagent_type_id = 'KAPA HiFi HS RM (2X)', manufacturer_lot, null)
    ) as kapa_hifi_hs_rm_lot_number,
    max(
        iff(reagent_type_id = '5hmC Labeling Buffer (10X)', manufacturer_lot, null)
    ) as hmc_labeling_buffer_lot_number,
    max(
        iff(reagent_type_id = 'Biotin Plate (Resuspended)', manufacturer_lot, null)
    ) as biotin_plate_lot_number,
    max(
        iff(reagent_type_id = 'Sequencing Adapter', manufacturer_lot, null)
    ) as sequencing_adapter_lot_number,
    max(
        iff(reagent_type_id = 'KAPA Hyper Prep Kit', manufacturer_lot, null)
    ) as kapa_hyper_prep_kit_lot_number,
    max(
        iff(reagent_type_id = 'UDP-Azide-Glucose', manufacturer_lot, null)
    ) as udp_azide_glucose_lot_number,
    max(
        iff(reagent_type_id = 'Beta-Glucosyltransferase', manufacturer_lot, null)
    ) as beta_glucosyltransferase_lot_number,
    max(
        iff(reagent_type_id = 'Dynabeads M270 Streptavidin', manufacturer_lot, null)
    ) as dynabeads_m270_streptavidin_lot_number,
    max(
        iff(reagent_type_id = '5hmC Wash Buffer (2X)', manufacturer_lot, null)
    ) as hmc_wash_buffer_lot_number,
    max(
        iff(reagent_type_id = 'Salmon Sperm DNA', manufacturer_lot, null)
    ) as salmon_sperm_dna_lot_number,
    max(
        iff(reagent_type_id = 'Spiked KAPA HiFi HS RM (2X)', manufacturer_lot, null)
    ) as spiked_kapa_hifi_hs_rm_lot_number,
    max(
        iff(reagent_type_id = 'Dynabeads MyOne Silane', manufacturer_lot, null)
    ) as dynabeads_myone_silane_lot_number,
    max(iff(reagent_type_id = 'SDS (20%)', manufacturer_lot, null)) as sds_lot_number,
    max(
        iff(reagent_type_id = 'MagMax Lysis Buffer', manufacturer_lot, null)
    ) as magmax_lysis_buffer_lot_number,
    max(
        iff(reagent_type_id = 'MagMax Elution Buffer', manufacturer_lot, null)
    ) as magmax_elution_buffer_lot_number,
    max(
        iff(reagent_type_id = 'MagMax Wash Buffer', manufacturer_lot, null)
    ) as magmax_wash_buffer_lot_number,
    max(iff(reagent_type_id = 'DMSO', manufacturer_lot, null)) as dmso_lot_number,
    max(iff(reagent_type_id = '2N NaOH', manufacturer_lot, null)) as naoh_2n_lot_number,
    max(
        iff(reagent_type_id = 'ERAL Cocktail Spike-In', manufacturer_lot, null)
    ) as eral_cocktail_spike_in_lot_number,
    max(
        iff(reagent_type_id = 'Spiked Proteinase K Mix', manufacturer_lot, null)
    ) as spiked_proteinase_k_mix_lot_number,
    max(
        iff(reagent_type_id = 'Spike-In Control', manufacturer_lot, null)
    ) as spike_in_control_lot_number,
    max(
        iff(reagent_type_id = 'Proteinase K', manufacturer_lot, null)
    ) as proteinase_k_lot_number,
    max(
        iff(
            reagent_type_id = 'NovaSeq 6000 SP Cluster Cartridge',
            manufacturer_lot,
            null
        )
    ) as novaseq_6000_sp_cluster_cartridge_lot_number,
    max(
        iff(reagent_type_id = 'NovaSeq 6000 SP Flow Cell', manufacturer_lot, null)
    ) as novaseq_6000_sp_flow_cell_lot_number,
    max(
        iff(reagent_type_id = 'NovaSeq 6000 S1 Flow Cell', manufacturer_lot, null)
    ) as novaseq_6000_s1_flow_cell_lot_number,
    max(
        iff(
            reagent_type_id = 'NovaSeq 6000 S1 Cluster Cartridge',
            manufacturer_lot,
            null
        )
    ) as novaseq_6000_s1_cluster_cartridge_lot_number,
    max(
        iff(reagent_type_id = 'NaOH (5M, pH 12)', manufacturer_lot, null)
    ) as naoh_5m_ph12_lot_number,
    max(
        iff(reagent_type_id = 'Tris-HCL (1M, pH 8.0)', manufacturer_lot, null)
    ) as tris_hcl_lot_number,
    max(
        iff(
            reagent_type_id = 'NovaSeq S2 Kit (200 cycles, v1.5)',
            manufacturer_lot,
            null
        )
    ) as novaseq_s2_kit_lot_number,
    max(
        iff(
            reagent_type_id = 'NovaSeq S1 Kit (200 cycles, v1.5)',
            manufacturer_lot,
            null
        )
    ) as novaseq_s1_kit_lot_number
from array_items
inner join {{ ref("reagent_lots") }} using (array_item_id)
group by 1
