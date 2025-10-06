CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(30) NOT NULL UNIQUE,
    role_desc TEXT NOT NULL,
    CONSTRAINT chk_role_name CHECK (role_name IN ('Guest', 'Creator', 'Supporter', 'Admin'))
) COMMENT='Table Role holds a limited pool of user role values – Guest, Creator, Supporter, Admin';

CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(70) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
) COMMENT='Table User represents unregistered (guests) and registered (creators, supporters, admins) users';

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_roles_roles FOREIGN KEY (role_id) REFERENCES roles(id)
) COMMENT='Table UserRole represents a junction table between User and Role';

CREATE TABLE creator_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    display_name VARCHAR(50) NOT NULL,
    about TEXT NOT NULL,
    became_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    profile_image_url VARCHAR(255),
    cover_image_url VARCHAR(255),
    CONSTRAINT fk_creatorprofiles_users FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT='Table CreatorProfile represents a profil of a user with a Creator role. One user (creator) can have only one profile';

CREATE TABLE post_visibilities (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_visibility_name VARCHAR(30) NOT NULL UNIQUE,
    post_visibility_desc TEXT NOT NULL,
    CONSTRAINT chk_post_visibility_name CHECK (post_visibility_name IN ('Public', 'SupportersOnly'))
) COMMENT='Table PostVisibility holds a limited pool of posts visibility values - Public and SupportersOnly';

CREATE TABLE posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_visibility_id BIGINT NOT NULL,
    creator_profile_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content_text TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    media_url VARCHAR(255),
    media_type VARCHAR(20),
    CONSTRAINT fk_posts_postvisibilities FOREIGN KEY (post_visibility_id) REFERENCES post_visibilities(id),
    CONSTRAINT fk_posts_creatorprofiles FOREIGN KEY (creator_profile_id) REFERENCES creator_profiles(id),
    CONSTRAINT chk_media_type CHECK (media_type IN ('Image', 'Audio', 'Video'))
) COMMENT='Table Post represents posts creators can public on their profiles';

CREATE TABLE comments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    post_id BIGINT NOT NULL,
    content_text TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_comments_posts FOREIGN KEY (post_id) REFERENCES posts(id)
) COMMENT='Table Comment represents comments registered users can leave under creators posts';

CREATE TABLE tiers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    tier_name VARCHAR(50) NOT NULL,
    tier_desc TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    CONSTRAINT chk_price CHECK (price >= 0),
    CONSTRAINT chk_currency CHECK (currency IN ('EUR', 'CZK', 'USD'))
) COMMENT='Table Tier represents subscription levels (only three) each creator can make';

CREATE TABLE subscriptions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    tier_id BIGINT NOT NULL,
    start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_date DATETIME NOT NULL,
    sub_status VARCHAR(30) NOT NULL,
    CONSTRAINT fk_subscriptions_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_subscriptions_tiers FOREIGN KEY (tier_id) REFERENCES tiers(id),
    CONSTRAINT chk_sub_status CHECK (sub_status IN ('Active', 'Canceled'))
) COMMENT='Table Subscription represents user subscription to a certain creator. Subscription is bind to a tier (level)';

CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    subscription_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    checkout_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    card_last4 CHAR(4) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    CONSTRAINT fk_payments_subscriptions FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Completed', 'Failed'))
) COMMENT='Table Payment represents users payments for subscriptions';
