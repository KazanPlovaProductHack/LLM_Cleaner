create_env_file:
	@if [ ! -f .env ]; then \
		echo "Creating .env file..."; \
		read -p "Enter TELEGRAM_BOTTOKEN: " TELEGRAM_BOTTOKEN; \
		read -p "Enter TELEGRAM_CHATID: " TELEGRAM_CHATID; \
		echo "TELEGRAM_BOTTOKEN=$$TELEGRAM_BOTTOKEN" > .env; \
		echo "TELEGRAM_CHATID=$$TELEGRAM_CHATID" >> .env; \
		echo ".env file created successfully."; \
	else \
		echo ".env file already exists. Skipping creation."; \
	fi

# Target to substitute environment variables in YAML file
substitute_env_vars: create_env_file
	@echo "Substituting environment variables in YAML file..."
	./substitute_env_vars.sh

get_model_weights: substitute_env_vars
	@echo "Download the model file..."
    gdown --id 1zOzt25XH_zCW47rfnNpKsIbc-O15H6wx -O ai_product_hack_model.zip

	@echo "Unzip the downloaded file..."
    unzip ai_product_hack_model.zip -d ./onnx && rm ai_product_hack_model.zip
    cp -r onnx inference/ && rm -rf ./onnx
	
llm_cleaner_init: get_model_weights

llm_cleaner_run: substitute_env_vars
	@echo "Setup and run software..."
	chmod +x setup.sh
	./setup.sh
