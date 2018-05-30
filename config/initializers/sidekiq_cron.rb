if Rails.env.production?
	Sidekiq::Cron::Job.create(name: 'Leafly News', cron: '10 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'LeaflyWorker')
	Sidekiq::Cron::Job.create(name: 'CannaLawBlog News', cron: '15 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'CannaLawBlogWorker')
	Sidekiq::Cron::Job.create(name: 'CannabisCulture News', cron: '20 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'CannabisCultureWorker')
	# Sidekiq::Cron::Job.create(name: 'DopeMagazine News', cron: '25 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'DopeMagazineWorker')
	# Sidekiq::Cron::Job.create(name: 'FourTwentyTimes News', cron: '30 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'FourTwentyTimesWorker')
	Sidekiq::Cron::Job.create(name: 'HighTimes News', cron: '35 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'HighTimesWorker')
	Sidekiq::Cron::Job.create(name: 'MarijuanaStocks News', cron: '40 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'MarijuanaStocksWorker')
	Sidekiq::Cron::Job.create(name: 'Marijuana.com News', cron: '45 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'MarijuanaWorker')
	Sidekiq::Cron::Job.create(name: 'MjBizDaily News', cron: '50 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'MjBizDailyWorker')
	Sidekiq::Cron::Job.create(name: 'TheCannabist News', cron: '55 0,2,4,6,8,10,12,14,16,18,20,22 * * *', class: 'TheCannabistWorker')

	# Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 1', cron: '0 3,7,11,15,19,23 * * *', class: 'WeedMapsWorker1')
	# Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 2', cron: '15 3,7,11,15,19,23 * * *', class: 'WeedMapsWorker2')
	# Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 3', cron: '30 3,7,11,15,19,23 * * *', class: 'WeedMapsWorker3')
	# Sidekiq::Cron::Job.create(name: 'Weedmaps Dispensary 4', cron: '45 3,7,11,15,19,23 * * *', class: 'WeedMapsWorker4')
	
	Sidekiq::Cron::Job.create(name: 'Leafly Disp WA 1', cron: '0 1,9,17 * * *', class: 'LeaflyDispensaryWorker1')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp WA 2', cron: '15 1,9,17 * * *', class: 'LeaflyDispensaryWorker2')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp WA 3', cron: '30 1,9,17 * * *', class: 'LeaflyDispensaryWorker3')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp WA 4', cron: '45 1,9,17 * * *', class: 'LeaflyDispensaryWorker4')
	
	Sidekiq::Cron::Job.create(name: 'Leafly Disp CO 5', cron: '0 3,11,19 * * *', class: 'LeaflyDispensaryWorker5')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp CO 6', cron: '15 3,11,19 * * *', class: 'LeaflyDispensaryWorker6')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp CO 7', cron: '30 3,11,19 * * *', class: 'LeaflyDispensaryWorker7')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp CO 8', cron: '45 3,11,19 * * *', class: 'LeaflyDispensaryWorker8')
	
	Sidekiq::Cron::Job.create(name: 'Leafly Disp NV 9', cron: '0 7,15,23 * * *', class: 'LeaflyDispensaryWorker9')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp NV 10', cron: '15 7,15,23 * * *', class: 'LeaflyDispensaryWorker10')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp NV 11', cron: '30 7,15,23 * * *', class: 'LeaflyDispensaryWorker11')
	Sidekiq::Cron::Job.create(name: 'Leafly Disp NV 12', cron: '45 7,15,23 * * *', class: 'LeaflyDispensaryWorker12')	

	Sidekiq::Cron::Job.create(name: 'Headset Scraper', cron: '0 0 * * *', class: 'HeadsetWorker')
end