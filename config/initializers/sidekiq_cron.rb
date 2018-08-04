if Rails.env.production?
	
	# NEWS
	Sidekiq::Cron::Job.create(name: 'News Leafly', cron: '10 2,6,10,14,18,22 * * *', class: 'LeaflyWorker')
	Sidekiq::Cron::Job.create(name: 'News CannaLawBlog', cron: '15 2,6,10,14,18,22 * * *', class: 'CannaLawBlogWorker')
	Sidekiq::Cron::Job.create(name: 'News CannabisCulture', cron: '20 2,6,10,14,18,22 * * *', class: 'CannabisCultureWorker')
	# Sidekiq::Cron::Job.create(name: 'DopeMagazine News', cron: '25 2,6,10,14,18,22 * * *', class: 'DopeMagazineWorker')
	# Sidekiq::Cron::Job.create(name: 'FourTwentyTimes News', cron: '30 2,6,10,14,18,22 * * *', class: 'FourTwentyTimesWorker')
	Sidekiq::Cron::Job.create(name: 'News HighTimes', cron: '35 2,6,10,14,18,22 * * *', class: 'HighTimesWorker')
	Sidekiq::Cron::Job.create(name: 'News MarijuanaStocks', cron: '40 2,6,10,14,18,22 * * *', class: 'MarijuanaStocksWorker')
	Sidekiq::Cron::Job.create(name: 'News Marijuana.com', cron: '45 2,6,10,14,18,22 * * *', class: 'MarijuanaWorker')
	Sidekiq::Cron::Job.create(name: 'News MjBizDaily', cron: '50 2,6,10,14,18,22 * * *', class: 'MjBizDailyWorker')
	Sidekiq::Cron::Job.create(name: 'News TheCannabist', cron: '55 2,6,10,14,18,22 * * *', class: 'TheCannabistWorker')
	
	# LEAFLY
	Sidekiq::Cron::Job.create(name: 'Leafly Disp WA', cron: '0 1 * * *', class: 'LeaflyDispensaryWorker1')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp CO', cron: '20 1 * * *', class: 'LeaflyDispensaryWorker2')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp NV', cron: '40 1 * * *', class: 'LeaflyDispensaryWorker3')
	
	#POTGUIDE
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 1', cron: '0 3 * * *', class: 'PotguideWorker1')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 2', cron: '30 3 * * *', class: 'PotguideWorker2')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 3', cron: '0 4 * * *', class: 'PotguideWorker3')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 4', cron: '30 4 * * *', class: 'PotguideWorker4')
	
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 5', cron: '0 5 * * *', class: 'PotguideWorker5')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 6', cron: '15 5 * * *', class: 'PotguideWorker6')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 7', cron: '30 5 * * *', class: 'PotguideWorker7')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 8', cron: '45 5 * * *', class: 'PotguideWorker8')

	# WEED MAPS
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 1', cron: '0 7 * * *', class: 'WeedMapsWorker1')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 2', cron: '15 7 * * *', class: 'WeedMapsWorker2')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 3', cron: '30 7 * * *', class: 'WeedMapsWorker3')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 4', cron: '45 7 * * *', class: 'WeedMapsWorker4')
	
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 5', cron: '0 9 * * *', class: 'WeedMapsWorker5')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 6', cron: '15 9 * * *', class: 'WeedMapsWorker6')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 7', cron: '30 9 * * *', class: 'WeedMapsWorker7')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 8', cron: '45 9 * * *', class: 'WeedMapsWorker8')
	
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 9', cron: '0 11 * * *', class: 'WeedMapsWorker9')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 10', cron: '15 11 * * *', class: 'WeedMapsWorker10')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 11', cron: '30 11 * * *', class: 'WeedMapsWorker11')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 12', cron: '45 11 * * *', class: 'WeedMapsWorker12')

	# HEADSET
	Sidekiq::Cron::Job.create(name: 'Headset Scraper', cron: '0 0 * * *', class: 'HeadsetWorker')
end