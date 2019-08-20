package protocol

import (
	"context"
	"crypto/sha256"
	"encoding/binary"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/tokenized/smart-contract/pkg/bitcoin"
)

// TransferOracleSigHash returns a Double SHA256 of the data required to identify a
//   token receiver approval by a oracle.
// The block hash of the chain tip - 4 should be used. The signature will be considered valid
//   until 1 hour past the timestamp of the block after the block hash specified (chain tip).
func TransferOracleSigHash(ctx context.Context, contractAddress bitcoin.RawAddress, assetCode []byte,
	receiverAddress bitcoin.RawAddress, quantity uint64, blockHash *chainhash.Hash) ([]byte, error) {

	// Calculate the hash
	digest := sha256.New()

	digest.Write(receiverAddress.Bytes())
	digest.Write(contractAddress.Bytes())
	digest.Write(assetCode)
	binary.Write(digest, DefaultEndian, &quantity)
	digest.Write(blockHash[:])

	approvedFlag := uint8(1)
	binary.Write(digest, DefaultEndian, &approvedFlag)

	hash := sha256.Sum256(digest.Sum(nil))
	return hash[:], nil
}
