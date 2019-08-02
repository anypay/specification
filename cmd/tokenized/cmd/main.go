package cmd

import (
	"github.com/spf13/cobra"
)

const (
	FlagDebugMode = "debug"
	FlagTestMode  = "test"
)

var scCmd = &cobra.Command{
	Use:   "tokenized",
	Short: "Tokenized CLI",
}

func Execute() {
	scCmd.AddCommand(cmdDecode)
	scCmd.AddCommand(cmdGenerate)
	scCmd.Execute()
}
