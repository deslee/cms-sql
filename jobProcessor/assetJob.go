package main

import (
	"context"
	"encoding/json"
	"path"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"
	"github.com/disintegration/imaging"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func ScanAssetList(ctx context.Context, db *sqlx.DB, query string, args ...interface{}) ([]Asset, error) {
	var list []Asset
	rows, err := db.Queryx(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var obj Asset
		err = rows.StructScan(&obj)
		if err != nil {
			return nil, err
		}
		list = append(list, obj)
	}
	return list, nil
}


func UpsertAsset(ctx context.Context, db *sqlx.DB, obj Asset) error {
	stmt, err := db.PrepareNamedContext(ctx, "INSERT INTO app_public.Asset VALUES (:id,:zone_id,:state,:type,:data,:created_by,:updated_by,:created_at,:updated_at) ON CONFLICT(id, zone_id) DO UPDATE SET \"id\"=excluded.\"id\",\"zone_id\"=excluded.\"zone_id\",\"state\"=excluded.\"state\",\"type\"=excluded.\"type\",\"data\"=excluded.\"data\",\"created_by\"=excluded.\"created_by\",\"updated_by\"=excluded.\"updated_by\",\"created_at\"=excluded.\"created_at\",\"updated_at\"=excluded.\"updated_at\"")
	if err != nil {
		return err
	}

	_, err = stmt.Exec(obj)
	if err != nil {
		return err
	}

	return err
}

type AuditFields struct {
	CreatedBy     *string `db:"created_by"`
	LastUpdatedBy *string `db:"updated_by"`
	CreatedAt     *string `db:"created_at"`
	LastUpdatedAt *string `db:"updated_at"`
}

type Asset struct {
	Id     string `db:"id"`
	ZoneId string `db:"zone_id"`
	State  string `db:"state"`
	Type   string `db:"type"`
	Data   string `db:"data"`
	AuditFields
}

func deserialize(jsonString string) map[string]interface{} {
	var f interface{}
	dataBytes := []byte(jsonString)
	err := json.Unmarshal(dataBytes, &f)
	if err != nil {
		log.Printf("Error found %s", err)
		return nil
	}
	data, ok := f.(map[string]interface{})
	if ok {
		return data
	} else {
		return nil
	}
}

// original filename. this is what the user sees
func (asset Asset) FileName() string {
	data := deserialize(asset.Data)
	originalFilename, ok := data["originalFilename"].(string)
	if ok {
		return originalFilename
	} else {
		log.Printf("Data.originalFilename is not a string! it is: %s", data["originalFilename"])
		return ""
	}
}

// filename saved to disk
func (asset Asset) Key() string {
	data := deserialize(asset.Data)
	originalFilename, ok := data["key"].(string)
	if ok {
		return originalFilename
	} else {
		log.Printf("Data.key is not a string! it is: %s", data["key"])
		return ""
	}
}

func (asset Asset) Extension() string {
	data := deserialize(asset.Data)
	extension, ok := data["extension"].(string)
	if ok {
		return extension
	} else {
		log.Printf("Data.extension is not a string! it is: %s", data["extension"])
		return ""
	}
}


var widths = []int{1200, 500, 320}

func main() {
	db, err := sqlx.Open("postgres", os.Getenv("CONNECTION_STRING"))
	if err != nil {
		panic(err)
	}
	ctx := context.Background()

	for {
		assets, err := ScanAssetList(ctx, db, "SELECT A.* FROM app_public.Asset A WHERE A.State=$1", "NONE")
		if err != nil {
			log.Printf("%s", err)
		}

		// TODO: maybe parallelize this?
		for _, asset := range assets {
			process(ctx, db, asset)
		}
		time.Sleep(1000 * time.Millisecond)
	}
}

func process(ctx context.Context, db *sqlx.DB, asset Asset) {
	log.Printf("Processing Asset %s", asset.Id)

	fileName := asset.Key()
	if len(fileName) == 0 {
		log.Print("Filename not found!")
		return
	}

	currentDir, err := os.Getwd()
	if err != nil {
		log.Print(err)
		return
	}

	filePath := path.Join(currentDir, os.Getenv("ASSETS_DIR"), fmt.Sprintf("%s", fileName))

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		log.Printf("File %s does not exist on disk!", filePath)
		return
	}

	src, err := imaging.Open(filePath)
	if err != nil {
		log.Print(err)
		return
	}

	sizes := make(map[string]string)

	log.Printf("Loaded asset %s", asset.Id)

	for _, w := range widths {
		// compute the width
		var width int
		if w < src.Bounds().Size().X {
			width = w
		} else {
			width = src.Bounds().Size().X
		}

		// compute the output file path
		key := fmt.Sprintf("%s-%d%s", asset.Id, width, asset.Extension())
		outputFilePath := fmt.Sprintf("./assets/%s", key)

		// widthHeightRatio := float64(src.Bounds().Size().Y) / float64(src.Bounds().Size().X)

		// resize the image
		resized := imaging.Resize(src, width, 0, imaging.Lanczos)

		// save the image
		err = imaging.Save(resized, outputFilePath)
		if err != nil {
			log.Print(err)
			return
		}

		// store the filepath in the map
		sizes[strconv.Itoa(width)] = key
	}

	// save the image
	var assetDataIf interface{}
	err = json.Unmarshal([]byte(asset.Data), &assetDataIf)
	if err != nil {
		log.Print(err)
		return
	}

	assetData, ok := assetDataIf.(map[string]interface{})
	if !ok {
		log.Printf("Could not deserialize asset data for asset %s", asset.Id)
		return
	}

	assetData["sizes"] = sizes
	jsonBytes, err := json.Marshal(assetData)
	if err != nil {
		log.Print(err)
		return
	}
	asset.Data = string(jsonBytes)
	asset.State = "RESIZED"
	err = UpsertAsset(ctx, db, asset)
	if err != nil {
		log.Print(err)
		return
	}
}