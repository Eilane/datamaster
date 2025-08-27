-- ========================================
-- Gatilho para atualizar "data_atualizacao" automaticamente
-- ========================================

CREATE OR REPLACE FUNCTION atualizar_data_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_data
BEFORE UPDATE ON clientes_pj
FOR EACH ROW
EXECUTE FUNCTION atualizar_data_atualizacao();
