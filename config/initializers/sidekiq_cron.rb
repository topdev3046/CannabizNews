if Rails.env.production?
	
	# NEWS - runs at 8am, 1pm, 6pm daily
	Sidekiq::Cron::Job.create(name: 'News Leafly', cron: '10 8,13,18 * * *', class: 'LeaflyWorker')
	Sidekiq::Cron::Job.create(name: 'News CannaLawBlog', cron: '15 8,13,18 * * *', class: 'CannaLawBlogWorker')
	Sidekiq::Cron::Job.create(name: 'News CannabisCulture', cron: '20 8,13,18 * * *', class: 'CannabisCultureWorker')
	# Sidekiq::Cron::Job.create(name: 'DopeMagazine News', cron: '25 8,13,18 * * *', class: 'DopeMagazineWorker')
	# Sidekiq::Cron::Job.create(name: 'FourTwentyTimes News', cron: '30 8,13,18 * * *', class: 'FourTwentyTimesWorker')
	Sidekiq::Cron::Job.create(name: 'News HighTimes', cron: '35 8,13,18 * * *', class: 'HighTimesWorker')
	Sidekiq::Cron::Job.create(name: 'News MarijuanaStocks', cron: '40 8,13,18 * * *', class: 'MarijuanaStocksWorker')
	Sidekiq::Cron::Job.create(name: 'News Marijuana.com', cron: '45 8,13,18 * * *', class: 'MarijuanaWorker')
	Sidekiq::Cron::Job.create(name: 'News MjBizDaily', cron: '50 8,13,18 * * *', class: 'MjBizDailyWorker')
	Sidekiq::Cron::Job.create(name: 'News TheCannabist', cron: '55 8,13,18 * * *', class: 'TheCannabistWorker')
	
	# LEAFLY - runs at 1 am - 3am daily
	Sidekiq::Cron::Job.create(name: 'Leafly Disp WA', cron: '0 1 * * *', class: 'LeaflyDispensaryWorker1')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp CO', cron: '0 2 * * *', class: 'LeaflyDispensaryWorker2')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp NV', cron: '0 3 * * *', class: 'LeaflyDispensaryWorker3')
	
	#POTGUIDE - runs at 4am - 7am, takes 8am break for news, runs 9am - 12pm
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 1', cron: '0 4 * * *', class: 'PotguideWorker5')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 2', cron: '0 5 * * *', class: 'PotguideWorker6')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 3', cron: '0 6 * * *', class: 'PotguideWorker7')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp CO 4', cron: '0 7 * * *', class: 'PotguideWorker8')

	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 1', cron: '0 9 * * *', class: 'PotguideWorker1')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 2', cron: '0 10 * * *', class: 'PotguideWorker2')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 3', cron: '0 11 * * *', class: 'PotguideWorker3')
	Sidekiq::Cron::Job.create(name: 'Potguide Disp WA 4', cron: '0 12 * * *', class: 'PotguideWorker4')

	# WEED MAPS - runs every 45 mins from 2pm - midnight with a break at 6pm for news
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 1', cron: '0 14 * * *', class: 'WeedMapsWorker5')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 2', cron: '45 14 * * *', class: 'WeedMapsWorker6')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 3', cron: '30 15 * * *', class: 'WeedMapsWorker7')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp CO 4', cron: '15 16 * * *', class: 'WeedMapsWorker8')
	
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 1', cron: '0 17 * * *', class: 'WeedMapsWorker9')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 2', cron: '0 19 * * *', class: 'WeedMapsWorker10')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 3', cron: '45 19 * * *', class: 'WeedMapsWorker11')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp NV 4', cron: '30 20 * * *', class: 'WeedMapsWorker12')

	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 1', cron: '15 21 * * *', class: 'WeedMapsWorker1')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 2', cron: '00 22 * * *', class: 'WeedMapsWorker2')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 3', cron: '45 22 * * *', class: 'WeedMapsWorker3')
	Sidekiq::Cron::Job.create(name: 'Weedmaps Disp WA 4', cron: '30 23 * * *', class: 'WeedMapsWorker4')

	# HEADSET - runs at 12:30am daily
	Sidekiq::Cron::Job.create(name: 'Headset Scraper', cron: '30 0 * * *', class: 'HeadsetWorker')
end