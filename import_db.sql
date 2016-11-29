DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(15),
  lname VARCHAR(15)
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(20),
  body TEXT,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id)  REFERENCES  questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  parent_reply_id INTEGER NOT NULL,
  body TEXT,

  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO users(fname, lname)
VALUES ('Soo-Rae', 'Hong'), ('Bohdan', 'Nakonechnyi');

INSERT INTO questions(title, body, user_id)
VALUES ('What''s for lunch?', 'What is for lunch everybody?',
  (SELECT
  id
  FROM
  users
  WHERE
  fname = 'Soo-Rae'
)), ('When is break?', 'It''s time to break?',
  (SELECT
  id
  FROM
  users
  WHERE
  fname = 'Bohdan'
));
